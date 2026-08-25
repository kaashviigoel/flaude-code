import json
from pathlib import Path

from app.services.openweather_service import normalize_alerts, normalize_current, normalize_forecast


def payload() -> dict:
    return json.loads((Path(__file__).parents[1] / "sample-data" / "onecall.json").read_text())


def test_current_normalization_converts_wind_and_preserves_nullable_fields():
    current = normalize_current(payload())
    assert current.temperature_c == 30.0
    assert current.wind_speed_kmph == 14.4
    assert current.rainfall_1h_mm == 2.4
    assert current.visibility_m == 8000


def test_forecast_normalization_supports_hourly_and_daily_shapes():
    forecast = normalize_forecast(payload())
    assert forecast.hourly[0].precipitation_probability == 0.8
    assert forecast.daily[0].temperature_min_c == 25.0
    assert forecast.daily[0].temperature_max_c == 32.0


def test_missing_alerts_return_empty_collection():
    assert normalize_alerts({}).items == []

