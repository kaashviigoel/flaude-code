from app.models.weather import WeatherForecast, WeatherNow
from app.services.personalization_service import Persona, build_recommendations
from app.services.weather_cache import WeatherCache


def test_cache_returns_fresh_then_stale_window():
    cache = WeatherCache()
    cache.set("test", {"temperature_c": 30})
    value, fresh = cache.get("test", 300)
    assert value == {"temperature_c": 30}
    assert fresh is True
    assert cache.get_stale("test", 300) == {"temperature_c": 30}


def test_recommendations_are_persona_aware():
    current = WeatherNow(temperature_c=36, humidity_pct=85, uv_index=8)
    recommendations = build_recommendations(current, WeatherForecast(), [], Persona.HEALTH)
    assert any("hydrated" in item for item in recommendations)
    assert len(recommendations) <= 5
