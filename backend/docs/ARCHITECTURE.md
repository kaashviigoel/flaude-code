# Architecture

## Purpose

MausamSense is a context-aware weather decision layer for the Flutter client. The backend owns OpenWeather access, normalization, resilience, persistence, and card ranking. Flutter consumes only the internal JSON contract.

## Runtime flow

```text
Flutter
  |
  | REST + JSON
  v
FastAPI routes
  |-- weather service -> cache -> retry -> OpenWeather One Call 4.0
  |                                  |
  |                                  v
  |                         normalized Pydantic models
  |
  |-- personalization service -> ranked cards + recommendations
  |
  `-- SQLAlchemy async session -> PostgreSQL
```

## Module ownership

| Module | Responsibility |
| --- | --- |
| `app/api/routes.py` | HTTP validation, dependency wiring, status codes |
| `app/services/openweather_service.py` | Provider request, retry policy, normalization orchestration |
| `app/services/weather_cache.py` | Process-local fresh/stale cache |
| `app/services/personalization_service.py` | Persona weights, card ranking, recommendations |
| `app/models/weather.py` | Stable weather and dashboard response contract |
| `app/models/user.py` | Preference and saved-location request/response contract |
| `app/db/` | Async SQLAlchemy engine, tables, and local initializer |
| `sample-data/` | Provider fixtures for offline tests |

## Design rules

1. OpenWeather credentials remain server-side.
2. Provider field names do not cross the API boundary.
3. Optional weather fields are nullable; missing upstream data must not break a dashboard response.
4. Personalization is deterministic and explainable for the MVP.
5. Database failures affect user-data endpoints, not weather endpoints.
6. The in-memory cache is a development/MVP optimization. Multiple production instances need a shared cache such as Redis.

## Request lifecycle

Weather requests first check the fresh cache. A miss triggers an OpenWeather request with bounded retries. A successful response is normalized and cached. If all attempts fail, a still-valid stale entry is returned with `data_status=stale`; otherwise the API returns `502`, `503`, or `504` depending on the failure.

