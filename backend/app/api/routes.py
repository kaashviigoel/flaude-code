from fastapi import APIRouter, Depends, Query

from app.models.weather import DashboardResponse, WeatherAlerts, WeatherForecast, WeatherNow
from app.services.openweather_service import OpenWeatherService
from app.services.personalization_service import Persona

router = APIRouter()


def get_weather_service() -> OpenWeatherService:
    return OpenWeatherService()


@router.get("/health", tags=["system"])
async def health() -> dict[str, str]:
    """Return a lightweight liveness response."""
    return {"status": "ok"}


@router.get("/api/weather/current", response_model=WeatherNow, tags=["weather"])
async def current_weather(
    lat: float = Query(..., ge=-90, le=90, description="Location latitude."),
    lon: float = Query(..., ge=-180, le=180, description="Location longitude."),
    service: OpenWeatherService = Depends(get_weather_service),
) -> WeatherNow:
    """Return normalized current conditions for a coordinate."""
    return (await service.get_weather(lat, lon)).current


@router.get("/api/weather/forecast", response_model=WeatherForecast, tags=["weather"])
async def forecast(
    lat: float = Query(..., ge=-90, le=90),
    lon: float = Query(..., ge=-180, le=180),
    service: OpenWeatherService = Depends(get_weather_service),
) -> WeatherForecast:
    """Return normalized hourly and daily forecast data."""
    return (await service.get_weather(lat, lon)).forecast


@router.get("/api/weather/alerts", response_model=WeatherAlerts, tags=["weather"])
async def alerts(
    lat: float = Query(..., ge=-90, le=90),
    lon: float = Query(..., ge=-180, le=180),
    service: OpenWeatherService = Depends(get_weather_service),
) -> WeatherAlerts:
    """Return normalized government or provider weather alerts."""
    return (await service.get_weather(lat, lon)).alerts


@router.get("/api/weather/dashboard", response_model=DashboardResponse, tags=["weather"])
async def dashboard(
    lat: float = Query(..., ge=-90, le=90),
    lon: float = Query(..., ge=-180, le=180),
    persona: Persona = Query(Persona.COMMUTER),
    service: OpenWeatherService = Depends(get_weather_service),
) -> DashboardResponse:
    """Return weather plus ranked, reusable cards for a user persona."""
    return await service.get_dashboard(lat, lon, persona)

