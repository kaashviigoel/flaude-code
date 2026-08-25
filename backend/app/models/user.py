from datetime import datetime

from pydantic import BaseModel, Field

from app.services.personalization_service import Persona


class UserPreferencesIn(BaseModel):
    persona: Persona = Persona.COMMUTER
    temperature_unit: str = Field(default="celsius", pattern="^(celsius|fahrenheit)$")
    notifications_enabled: bool = True


class UserPreferencesOut(UserPreferencesIn):
    user_id: str
    updated_at: datetime | None = None


class SavedLocationIn(BaseModel):
    name: str = Field(min_length=1, max_length=120)
    latitude: float = Field(ge=-90, le=90)
    longitude: float = Field(ge=-180, le=180)


class SavedLocationOut(SavedLocationIn):
    id: int
    user_id: str
    created_at: datetime | None = None

