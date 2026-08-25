import asyncio
from datetime import datetime, timezone

import httpx
from fastapi import HTTPException

from app.core.config import get_settings
from app.models.weather import (
    DashboardResponse,
    ForecastPeriod,
    Location,
    WeatherAlert,
    WeatherAlerts,
    WeatherForecast,
    WeatherNow,
)
from app.services.personalization_service import (
    Persona,
    build_recommendations,
    rank_cards,
)
from app.services.weather_cache import weather_cache


def _dt(value: int | float | None) -> datetime | None:
    return (
        datetime.fromtimestamp(value, tz=timezone.utc)
        if value is not None
        else None
    )


def _wind_kmph(value: float | None) -> float | None:
    return value * 3.6 if value is not None else None


# ============================================================
# CURRENT WEATHER
# ============================================================

def normalize_current(payload: dict) -> WeatherNow:
    weather = (payload.get("weather") or [{}])[0]
    main = payload.get("main") or {}
    wind = payload.get("wind") or {}
    rain = payload.get("rain") or {}

    return WeatherNow(
        observed_at=_dt(payload.get("dt")),
        temperature_c=main.get("temp"),
        feels_like_c=main.get("feels_like"),
        humidity_pct=main.get("humidity"),
        pressure_hpa=main.get("pressure"),
        wind_speed_kmph=_wind_kmph(wind.get("speed")),
        wind_direction_deg=wind.get("deg"),
        visibility_m=payload.get("visibility"),
        rainfall_1h_mm=rain.get("1h"),
        uv_index=None,
        weather_code=weather.get("id"),
        weather_description=weather.get("description"),
    )


# ============================================================
# FORECAST
# ============================================================

def normalize_forecast(payload: dict) -> WeatherForecast:
    """
    OpenWeather 5-day / 3-hour forecast returns:
        list: [
            {
                dt,
                main,
                weather,
                wind,
                pop,
                rain,
                ...
            }
        ]

    We expose those forecast points through the same
    ForecastPeriod model used by the Flutter application.
    """

    periods = []

    for item in payload.get("list", []):
        weather = (item.get("weather") or [{}])[0]
        main = item.get("main") or {}
        wind = item.get("wind") or {}
        rain = item.get("rain") or {}

        periods.append(
            ForecastPeriod(
                starts_at=_dt(item.get("dt")),
                temperature_c=main.get("temp"),
                temperature_min_c=main.get("temp_min"),
                temperature_max_c=main.get("temp_max"),
                feels_like_c=main.get("feels_like"),
                humidity_pct=main.get("humidity"),
                precipitation_probability=item.get("pop"),
                rainfall_mm=(
                    rain.get("3h")
                    or rain.get("1h")
                ),
                wind_speed_kmph=_wind_kmph(
                    wind.get("speed")
                ),
                weather_code=weather.get("id"),
                weather_description=weather.get(
                    "description"
                ),
            )
        )

    # The Flutter app expects an hourly list.
    #
    # The free 5-day endpoint gives 3-hour intervals,
    # so we expose those intervals as the available
    # forecast periods.
    hourly = periods

    # Build a simple daily representation from the
    # available 3-hour forecast data.
    daily = []

    seen_dates = set()

    for period in periods:
        if period.starts_at is None:
            continue

        date_key = period.starts_at.date()

        if date_key in seen_dates:
            continue

        seen_dates.add(date_key)

        same_day = [
            p
            for p in periods
            if p.starts_at is not None
            and p.starts_at.date() == date_key
        ]

        temperatures = [
            p.temperature_c
            for p in same_day
            if p.temperature_c is not None
        ]

        if not temperatures:
            continue

        daily.append(
            ForecastPeriod(
                starts_at=period.starts_at,
                temperature_c=sum(temperatures)
                / len(temperatures),
                temperature_min_c=min(temperatures),
                temperature_max_c=max(temperatures),
                feels_like_c=period.feels_like_c,
                humidity_pct=period.humidity_pct,
                precipitation_probability=max(
                    (
                        p.precipitation_probability
                        for p in same_day
                        if p.precipitation_probability
                        is not None
                    ),
                    default=None,
                ),
                rainfall_mm=sum(
                    (
                        p.rainfall_mm or 0
                        for p in same_day
                    )
                ),
                wind_speed_kmph=period.wind_speed_kmph,
                weather_code=period.weather_code,
                weather_description=(
                    period.weather_description
                ),
            )
        )

    return WeatherForecast(
        hourly=hourly,
        daily=daily,
    )


# ============================================================
# ALERTS
# ============================================================

def normalize_alerts() -> WeatherAlerts:
    """
    The basic OpenWeather current/forecast endpoints do not
    provide One Call weather alerts.

    Return an empty alert list instead of inventing alerts.
    """

    return WeatherAlerts(items=[])


# ============================================================
# OPENWEATHER SERVICE
# ============================================================

class OpenWeatherService:
    """
    Fetches weather using OpenWeather endpoints that do not
    require One Call 3.0.

    Current:
        /weather

    Forecast:
        /forecast
    """

    async def get_weather(
        self,
        lat: float,
        lon: float,
    ) -> DashboardResponse:

        settings = get_settings()

        cache_key = f"{lat:.4f}:{lon:.4f}"

        cached, is_fresh = weather_cache.get(
            cache_key,
            settings.weather_cache_ttl_seconds,
        )

        if is_fresh:
            cached.data_status = "cached"
            cached.data_warning = None
            return cached

        # ----------------------------------------------------
        # API KEY
        # ----------------------------------------------------

        if (
            not settings.openweather_api_key
            or settings.openweather_api_key
            == "replace-with-your-key"
        ):
            stale = weather_cache.get_stale(
                cache_key,
                settings.weather_cache_stale_seconds,
            )

            if stale is not None:
                stale.data_status = "stale"
                stale.data_warning = (
                    "OpenWeather API key is not configured; "
                    "showing cached data"
                )
                return stale

            raise HTTPException(
                status_code=503,
                detail=(
                    "OpenWeather API key is missing "
                    "or still uses the placeholder value"
                ),
            )

        params = {
            "lat": lat,
            "lon": lon,
            "appid": settings.openweather_api_key,
            "units": "metric",
        }

        last_error: Exception | None = None

        # ----------------------------------------------------
        # FETCH CURRENT + FORECAST
        # ----------------------------------------------------

        for attempt in range(
            settings.openweather_max_retries + 1
        ):

            try:

                async with httpx.AsyncClient(
                    timeout=settings.openweather_timeout_seconds
                ) as client:

                    current_response = await client.get(
                        f"{settings.openweather_base_url}"
                        .replace("/data/3.0", "/data/2.5")
                        + "/weather",
                        params=params,
                    )

                    current_response.raise_for_status()

                    forecast_response = await client.get(
                        f"{settings.openweather_base_url}"
                        .replace("/data/3.0", "/data/2.5")
                        + "/forecast",
                        params=params,
                    )

                    forecast_response.raise_for_status()

                current_payload = current_response.json()
                forecast_payload = forecast_response.json()

                current = normalize_current(
                    current_payload
                )

                forecast = normalize_forecast(
                    forecast_payload
                )

                alerts = normalize_alerts()

                dashboard = self.normalize(
                    lat=lat,
                    lon=lon,
                    current=current,
                    forecast=forecast,
                    alerts=alerts,
                )

                weather_cache.set(
                    cache_key,
                    dashboard,
                )

                return dashboard

            except (
                httpx.TimeoutException,
                httpx.HTTPError,
                ValueError,
            ) as exc:

                last_error = exc

                if attempt < settings.openweather_max_retries:
                    await asyncio.sleep(
                        0.25 * (2 ** attempt)
                    )

        # ----------------------------------------------------
        # FALLBACK TO CACHE
        # ----------------------------------------------------

        stale = weather_cache.get_stale(
            cache_key,
            settings.weather_cache_stale_seconds,
        )

        if stale is not None:
            stale.data_status = "stale"
            stale.data_warning = (
                "OpenWeather unavailable; "
                "showing cached data"
            )
            return stale

        # ----------------------------------------------------
        # ERRORS
        # ----------------------------------------------------

        if isinstance(
            last_error,
            httpx.TimeoutException,
        ):
            raise HTTPException(
                status_code=504,
                detail="OpenWeather request timed out",
            ) from last_error

        if isinstance(
            last_error,
            httpx.HTTPStatusError,
        ):

            status_code = (
                last_error.response.status_code
            )

            if status_code == 401:
                raise HTTPException(
                    status_code=503,
                    detail=(
                        "OpenWeather API key is invalid "
                        "or not authorized"
                    ),
                ) from last_error

            if status_code == 429:
                raise HTTPException(
                    status_code=429,
                    detail=(
                        "OpenWeather rate limit exceeded"
                    ),
                ) from last_error

            raise HTTPException(
                status_code=502,
                detail="OpenWeather request failed",
            ) from last_error

        raise HTTPException(
            status_code=502,
            detail="OpenWeather is unavailable",
        ) from last_error

    # ========================================================
    # DASHBOARD NORMALIZATION
    # ========================================================

    @staticmethod
    def normalize(
        lat: float,
        lon: float,
        current: WeatherNow,
        forecast: WeatherForecast,
        alerts: WeatherAlerts,
    ) -> DashboardResponse:

        default_persona = Persona.COMMUTER

        return DashboardResponse(
            location=Location(
                latitude=lat,
                longitude=lon,
            ),

            current=current,

            forecast=forecast,

            alerts=alerts,

            cards=rank_cards(
                current,
                forecast,
                alerts.items,
                default_persona,
            ),

            persona=default_persona.value,

            fetched_at=datetime.now(
                timezone.utc
            ),

            data_status="fresh",

            recommendations=build_recommendations(
                current,
                forecast,
                alerts.items,
                default_persona,
            ),
        )

    # ========================================================
    # PERSONA DASHBOARD
    # ========================================================

    async def get_dashboard(
        self,
        lat: float,
        lon: float,
        persona: Persona,
    ) -> DashboardResponse:

        dashboard = await self.get_weather(
            lat,
            lon,
        )

        dashboard.cards = rank_cards(
            dashboard.current,
            dashboard.forecast,
            dashboard.alerts.items,
            persona,
        )

        dashboard.persona = persona.value

        dashboard.recommendations = (
            build_recommendations(
                dashboard.current,
                dashboard.forecast,
                dashboard.alerts.items,
                persona,
            )
        )

        return dashboard