from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Runtime configuration loaded from environment variables or .env."""

    openweather_api_key: str = ""
    openweather_base_url: str = "https://api.openweathermap.org/data/3.0"
    openweather_timeout_seconds: float = 10.0
    weather_cache_ttl_seconds: int = 300
    weather_cache_stale_seconds: int = 3600
    openweather_max_retries: int = 2
    database_url: str = "postgresql+asyncpg://postgres:postgres@localhost:5432/mausam"

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")


@lru_cache
def get_settings() -> Settings:
    return Settings()
