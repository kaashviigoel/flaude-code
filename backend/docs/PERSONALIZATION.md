# Personalization

## Inputs

The scoring engine uses normalized current conditions, the first six hourly forecast periods, active alerts, and the selected persona.

## Score factors

Every factor is normalized to `0..1`, multiplied by the persona weight, clamped to `0..1`, and sorted descending.

| Factor | Signal |
| --- | --- |
| Rain | Highest precipitation probability in the next six hourly periods |
| Heat | Current temperature above the 24 C comfort baseline, capped at 40 C |
| UV | UV index divided by 11 |
| Wind | Wind speed divided by 50 km/h |
| Visibility | Inverse of visibility relative to 10 km |
| Alerts | `1` when at least one alert exists, otherwise `0` |
| Humidity | Humidity above the 50% baseline |

## Persona emphasis

| Persona | Highest priorities |
| --- | --- |
| Fitness | Heat, UV, rain, wind |
| Traveller | Alerts, rain, visibility, wind |
| Health | Heat, UV, humidity, alerts |
| Commuter | Rain, alerts, visibility, wind |

Cards are reusable across personas. The persona changes priority and visibility rather than creating a separate homepage implementation.

## Recommendations

Recommendations are deterministic rule-based messages. They can be replaced later by a richer rules engine or model without changing the dashboard response shape. At most five recommendations are returned, and active alerts are surfaced first.

