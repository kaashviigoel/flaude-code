from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from typing import Any


@dataclass
class CacheEntry:
    value: Any
    stored_at: datetime


class WeatherCache:
    """Small process-local cache with a stale-read window for provider outages."""

    def __init__(self) -> None:
        self._entries: dict[str, CacheEntry] = {}

    def get(self, key: str, max_age_seconds: int) -> tuple[Any | None, bool]:
        entry = self._entries.get(key)
        if entry is None:
            return None, False
        age = datetime.now(timezone.utc) - entry.stored_at
        if age <= timedelta(seconds=max_age_seconds):
            return entry.value, True
        return None, False

    def get_stale(self, key: str, max_age_seconds: int) -> Any | None:
        entry = self._entries.get(key)
        if entry is None:
            return None
        age = datetime.now(timezone.utc) - entry.stored_at
        return entry.value if age <= timedelta(seconds=max_age_seconds) else None

    def set(self, key: str, value: Any) -> None:
        self._entries[key] = CacheEntry(value=value, stored_at=datetime.now(timezone.utc))


weather_cache = WeatherCache()

