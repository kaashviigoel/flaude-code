from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import delete, select
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.database import get_db
from app.db.tables import SavedLocation, UserPreference
from app.models.user import SavedLocationIn, SavedLocationOut, UserPreferencesIn, UserPreferencesOut
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


@router.put("/api/users/{user_id}/preferences", response_model=UserPreferencesOut, tags=["users"])
async def save_preferences(user_id: str, body: UserPreferencesIn, db: AsyncSession = Depends(get_db)) -> UserPreferencesOut:
    """Create or replace a user's personalization preferences."""
    try:
        item = await db.get(UserPreference, user_id)
        if item is None:
            item = UserPreference(user_id=user_id)
            db.add(item)
        item.persona = body.persona.value
        item.temperature_unit = body.temperature_unit
        item.notifications_enabled = body.notifications_enabled
        await db.commit()
        await db.refresh(item)
        return UserPreferencesOut.model_validate(item, from_attributes=True)
    except SQLAlchemyError as exc:
        await db.rollback()
        raise HTTPException(status_code=503, detail="Database is unavailable") from exc


@router.get("/api/users/{user_id}/preferences", response_model=UserPreferencesOut, tags=["users"])
async def get_preferences(user_id: str, db: AsyncSession = Depends(get_db)) -> UserPreferencesOut:
    """Return saved personalization preferences for a user."""
    try:
        item = await db.get(UserPreference, user_id)
    except SQLAlchemyError as exc:
        raise HTTPException(status_code=503, detail="Database is unavailable") from exc
    if item is None:
        raise HTTPException(status_code=404, detail="Preferences not found")
    return UserPreferencesOut.model_validate(item, from_attributes=True)


@router.post("/api/users/{user_id}/locations", response_model=SavedLocationOut, status_code=201, tags=["users"])
async def add_location(user_id: str, body: SavedLocationIn, db: AsyncSession = Depends(get_db)) -> SavedLocationOut:
    """Save a named coordinate for a user."""
    try:
        item = SavedLocation(user_id=user_id, **body.model_dump())
        db.add(item)
        await db.commit()
        await db.refresh(item)
        return SavedLocationOut.model_validate(item, from_attributes=True)
    except SQLAlchemyError as exc:
        await db.rollback()
        raise HTTPException(status_code=503, detail="Database is unavailable") from exc


@router.get("/api/users/{user_id}/locations", response_model=list[SavedLocationOut], tags=["users"])
async def list_locations(user_id: str, db: AsyncSession = Depends(get_db)) -> list[SavedLocationOut]:
    """List saved locations for a user."""
    try:
        result = await db.execute(select(SavedLocation).where(SavedLocation.user_id == user_id).order_by(SavedLocation.created_at.desc()))
        return [SavedLocationOut.model_validate(item, from_attributes=True) for item in result.scalars()]
    except SQLAlchemyError as exc:
        raise HTTPException(status_code=503, detail="Database is unavailable") from exc


@router.delete("/api/users/{user_id}/locations/{location_id}", status_code=204, tags=["users"])
async def delete_location(user_id: str, location_id: int, db: AsyncSession = Depends(get_db)) -> None:
    """Delete one saved location owned by a user."""
    try:
        result = await db.execute(delete(SavedLocation).where(SavedLocation.id == location_id, SavedLocation.user_id == user_id))
        if result.rowcount == 0:
            raise HTTPException(status_code=404, detail="Location not found")
        await db.commit()
    except SQLAlchemyError as exc:
        await db.rollback()
        raise HTTPException(status_code=503, detail="Database is unavailable") from exc
