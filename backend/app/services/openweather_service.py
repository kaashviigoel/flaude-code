import asyncio
from datetime import datetime, timezone

import httpx
from fastapi import HTTPException

from app.core.config import get_settings
from app.models.weather import DashboardResponse, ForecastPeriod, Location, WeatherAlert, WeatherAlerts, WeatherForecast, WeatherNow
from app.services.personalization_service import Persona, build_recommendations, rank_cards
from app.services.weather_cache import weather_cache


def _dt(value: int | float | None) -> datetime | None:
    return datetime.fromtimestamp(value, tz=timezone.utc) if value is not None else None


def _wind_kmph(value: float | None) -> float | None:
    return value * 3.6 if value is not None else None


def normalize_current(payload: dict) -> WeatherNow:
    current = payload.get("current", {})
    weather = (current.get("weather") or [{}])[0]
    rain = current.get("rain") or {}
    return WeatherNow(
        observed_at=_dt(current.get("dt")),
        temperature_c=current.get("temp"),
        feels_like_c=current.get("feels_like"),
        humidity_pct=current.get("humidity"),
        pressure_hpa=current.get("pressure"),
        wind_speed_kmph=_wind_kmph(current.get("wind_speed")),
        wind_direction_deg=current.get("wind_deg"),
        visibility_m=current.get("visibility"),
        rainfall_1h_mm=rain.get("1h"),
        uv_index=current.get("uvi"),
        weather_code=weather.get("id"),
        weather_description=weather.get("description"),
    )


def _period(item: dict, daily: bool = False) -> ForecastPeriod:
    weather = (item.get("weather") or [{}])[0]
    temperatures = item.get("temp") or {}
    main = item.get("main") or {}
    rain = item.get("rain") or {}
    return ForecastPeriod(
        starts_at=_dt(item.get("dt")),
        temperature_c=temperatures.get("day") if daily else main.get("temp"),
        temperature_min_c=temperatures.get("min") if daily else None,
        temperature_max_c=temperatures.get("max") if daily else None,
        feels_like_c=temperatures.get("feels_like") if daily else main.get("feels_like"),
        humidity_pct=temperatures.get("humidity") if daily else main.get("humidity"),
        precipitation_probability=item.get("pop"),
        rainfall_mm=rain.get("1h") or rain.get("3h"),
        wind_speed_kmph=_wind_kmph(item.get("wind_speed")),
        weather_code=weather.get("id"),
        weather_description=weather.get("description"),
    )


def normalize_forecast(payload: dict) -> WeatherForecast:
    return WeatherForecast(
        hourly=[_period(item) for item in (payload.get("hourly") or [])],
        daily=[_period(item, daily=True) for item in (payload.get("daily") or [])],
    )


def normalize_alerts(payload: dict) -> WeatherAlerts:
    return WeatherAlerts(items=[WeatherAlert(
        sender=item.get("sender_name"),
        event=item.get("event"),
        severity=None,
        starts_at=_dt(item.get("start")),
        ends_at=_dt(item.get("end")),
        description=item.get("description"),
    ) for item in (payload.get("alerts") or [])])


class OpenWeatherService:
    """Fetches and normalizes OpenWeather One Call API 4.0 responses."""

    async def get_weather(self, lat: float, lon: float) -> DashboardResponse:
        settings = get_settings()
        cache_key = f"{lat:.4f}:{lon:.4f}"
        cached, is_fresh = weather_cache.get(cache_key, settings.weather_cache_ttl_seconds)
        if is_fresh:
            cached.data_status = "cached"
            cached.data_warning = None
            return cached
        if not settings.openweather_api_key:
            stale = weather_cache.get_stale(cache_key, settings.weather_cache_stale_seconds)
            if stale is not None:
                stale.data_status = "stale"
                stale.data_warning = "OpenWeather API key is not configured; showing cached data"
                return stale
            raise HTTPException(status_code=503, detail="OpenWeather API key is not configured")
        params = {"lat": lat, "lon": lon, "appid": settings.openweather_api_key, "units": "metric"}
        last_error: Exception | None = None
        for attempt in range(settings.openweather_max_retries + 1):
            try:
                async with httpx.AsyncClient(timeout=settings.openweather_timeout_seconds) as client:
                    response = await client.get(f"{settings.openweather_base_url}/onecall", params=params)
                response.raise_for_status()
                dashboard = self.normalize(lat, lon, response.json())
                weather_cache.set(cache_key, dashboard)
                return dashboard
            except (httpx.TimeoutException, httpx.HTTPError, ValueError) as exc:
                last_error = exc
                if attempt < settings.openweather_max_retries:
                    await asyncio.sleep(0.25 * (2**attempt))
        stale = weather_cache.get_stale(cache_key, settings.weather_cache_stale_seconds)
        if stale is not None:
            stale.data_status = "stale"
            stale.data_warning = "OpenWeather unavailable; showing cached data"
            return stale
        if isinstance(last_error, httpx.TimeoutException):
            raise HTTPException(status_code=504, detail="OpenWeather request timed out") from last_error
        if isinstance(last_error, httpx.HTTPStatusError):
            status = 429 if last_error.response.status_code == 429 else 502
            raise HTTPException(status_code=status, detail="OpenWeather request failed") from last_error
        raise HTTPException(status_code=502, detail="OpenWeather is unavailable") from last_error

    @staticmethod
    def normalize(lat: float, lon: float, payload: dict) -> DashboardResponse:
        current = normalize_current(payload)
        forecast = normalize_forecast(payload)
        alerts = normalize_alerts(payload)
        return DashboardResponse(
            location=Location(latitude=lat, longitude=lon),
            current=current,
            forecast=forecast,
            alerts=alerts,
            cards=rank_cards(current, forecast, alerts.items, Persona.COMMUTER),
            persona=Persona.COMMUTER.value,
            fetched_at=datetime.now(timezone.utc),
            data_status="fresh",
            recommendations=build_recommendations(current, forecast, alerts.items, Persona.COMMUTER),
        )

    async def get_dashboard(self, lat: float, lon: float, persona: Persona) -> DashboardResponse:
        dashboard = await self.get_weather(lat, lon)
        dashboard.cards = rank_cards(dashboard.current, dashboard.forecast, dashboard.alerts.items, persona)
        dashboard.persona = persona.value
        dashboard.recommendations = build_recommendations(dashboard.current, dashboard.forecast, dashboard.alerts.items, persona)
        return dashboard
