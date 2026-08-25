from enum import Enum

from app.models.weather import DashboardResponse, WeatherAlert, WeatherCard, WeatherForecast, WeatherNow


class Persona(str, Enum):
    FITNESS = "fitness"
    TRAVELLER = "traveller"
    HEALTH = "health"
    COMMUTER = "commuter"


PERSONA_WEIGHTS: dict[Persona, dict[str, float]] = {
    Persona.FITNESS: {"heat": 1.0, "uv": 0.95, "rain": 0.9, "wind": 0.7, "visibility": 0.4},
    Persona.TRAVELLER: {"rain": 0.9, "alerts": 1.0, "heat": 0.6, "visibility": 0.8, "wind": 0.7},
    Persona.HEALTH: {"heat": 0.9, "uv": 0.9, "humidity": 0.8, "alerts": 0.9, "rain": 0.3},
    Persona.COMMUTER: {"rain": 1.0, "alerts": 1.0, "visibility": 0.95, "wind": 0.8, "heat": 0.3},
}


def _clamp(value: float) -> float:
    return max(0.0, min(1.0, value))


def rank_cards(current: WeatherNow, forecast: WeatherForecast, alerts: list[WeatherAlert], persona: Persona) -> list[WeatherCard]:
    weights = PERSONA_WEIGHTS[persona]
    rain = max((item.precipitation_probability or 0 for item in forecast.hourly[:6]), default=0.0)
    heat = _clamp(((current.temperature_c or 20) - 24) / 16)
    uv = _clamp((current.uv_index or 0) / 11)
    wind = _clamp((current.wind_speed_kmph or 0) / 50)
    visibility = _clamp(1 - (current.visibility_m or 10000) / 10000)
    alert_score = 1.0 if alerts else 0.0
    values = {"rain": rain, "heat": heat, "uv": uv, "wind": wind, "visibility": visibility, "alerts": alert_score, "humidity": _clamp(((current.humidity_pct or 50) - 50) / 50)}
    cards = [
        WeatherCard(card_id="weather_summary", title="Current weather", priority=0.5, visible=True, reason="Baseline conditions", data={"temperature_c": current.temperature_c}),
        WeatherCard(card_id="rain_alert", title="Rain outlook", priority=_clamp(values["rain"] * weights["rain"]), visible=rain > 0.1, reason="Near-term precipitation probability", data={"probability": rain}),
        WeatherCard(card_id="heat_alert", title="Heat awareness", priority=_clamp(values["heat"] * weights["heat"]), visible=heat > 0.15, reason="Current temperature relative to comfort range", data={"temperature_c": current.temperature_c}),
        WeatherCard(card_id="uv_index", title="UV index", priority=_clamp(values["uv"] * weights["uv"]), visible=current.uv_index is not None, reason="Sun exposure risk", data={"uv_index": current.uv_index}),
        WeatherCard(card_id="travel_risk", title="Travel risk", priority=_clamp(max(values["alerts"] * weights["alerts"], values["visibility"] * weights["visibility"])), visible=bool(alerts) or visibility > 0.1, reason="Alerts and visibility affect travel", data={"alert_count": len(alerts), "visibility_m": current.visibility_m}),
    ]
    return sorted(cards, key=lambda card: card.priority, reverse=True)

