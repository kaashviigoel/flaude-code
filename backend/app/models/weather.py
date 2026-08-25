from datetime import datetime

from pydantic import BaseModel, Field


class Location(BaseModel):
    latitude: float
    longitude: float
    name: str | None = None


class WeatherNow(BaseModel):
    observed_at: datetime | None = None
    temperature_c: float | None = None
    feels_like_c: float | None = None
    humidity_pct: float | None = Field(default=None, ge=0, le=100)
    pressure_hpa: float | None = None
    wind_speed_kmph: float | None = None
    wind_direction_deg: float | None = None
    visibility_m: float | None = None
    rainfall_1h_mm: float | None = None
    uv_index: float | None = None
    weather_code: int | None = None
    weather_description: str | None = None


class ForecastPeriod(BaseModel):
    starts_at: datetime | None = None
    temperature_c: float | None = None
    temperature_min_c: float | None = None
    temperature_max_c: float | None = None
    feels_like_c: float | None = None
    humidity_pct: float | None = None
    precipitation_probability: float | None = Field(default=None, ge=0, le=1)
    rainfall_mm: float | None = None
    wind_speed_kmph: float | None = None
    weather_code: int | None = None
    weather_description: str | None = None


class WeatherForecast(BaseModel):
    hourly: list[ForecastPeriod] = Field(default_factory=list)
    daily: list[ForecastPeriod] = Field(default_factory=list)


class WeatherAlert(BaseModel):
    sender: str | None = None
    event: str | None = None
    severity: str | None = None
    starts_at: datetime | None = None
    ends_at: datetime | None = None
    description: str | None = None


class WeatherAlerts(BaseModel):
    items: list[WeatherAlert] = Field(default_factory=list)


class WeatherCard(BaseModel):
    card_id: str
    title: str
    priority: float = Field(ge=0, le=1)
    visible: bool
    reason: str
    data: dict[str, object] = Field(default_factory=dict)


class DashboardResponse(BaseModel):
    location: Location
    current: WeatherNow
    forecast: WeatherForecast
    alerts: WeatherAlerts
    cards: list[WeatherCard] = Field(default_factory=list)
    persona: str
    source: str = "OpenWeather"
    fetched_at: datetime
    data_status: str = "fresh"
    data_warning: str | None = None
    recommendations: list[str] = Field(default_factory=list)
