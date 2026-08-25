import json
from pathlib import Path

from app.models.weather import WeatherAlerts
from app.services.openweather_service import normalize_current, normalize_forecast
from app.services.personalization_service import Persona, rank_cards


def test_personas_prioritize_different_cards():
    payload = json.loads((Path(__file__).parents[1] / "sample-data" / "onecall.json").read_text())
    current = normalize_current(payload)
    forecast = normalize_forecast(payload)
    alerts = WeatherAlerts(items=[]).items
    fitness = rank_cards(current, forecast, alerts, Persona.FITNESS)
    commuter = rank_cards(current, forecast, alerts, Persona.COMMUTER)
    fitness_uv = next(card for card in fitness if card.card_id == "uv_index")
    commuter_uv = next(card for card in commuter if card.card_id == "uv_index")
    assert fitness_uv.priority > commuter_uv.priority
