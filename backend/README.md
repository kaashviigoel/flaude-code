# MausamSense Backend

FastAPI service for the MausamSense Flutter application. This MVP uses OpenWeather One Call API 4.0 as its only external weather provider.

## Local setup

```powershell
cd backend
py -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
Copy-Item .env.example .env
# Set OPENWEATHER_API_KEY in .env
uvicorn app.main:app --reload
```

Interactive API documentation is available at `http://127.0.0.1:8000/docs`; the alternative ReDoc view is at `/redoc`.

## Endpoints

All weather endpoints require `lat` and `lon` query parameters. Coordinates are validated before an OpenWeather request is made.

| Method | Endpoint | Purpose |
| --- | --- | --- |
| GET | `/health` | Liveness check |
| GET | `/api/weather/current` | Normalized current conditions |
| GET | `/api/weather/forecast` | Hourly and daily forecast |
| GET | `/api/weather/alerts` | Normalized alerts |
| GET | `/api/weather/dashboard` | Conditions, forecast, alerts, and ranked cards |

The dashboard also accepts `persona=fitness`, `traveller`, `health`, or `commuter`.

## Data flow

```text
Flutter -> FastAPI -> OpenWeather -> normalizer -> internal Pydantic models -> ranked cards
```

OpenWeather credentials and provider-specific response shapes never leave the backend. Missing optional values are represented as `null`.

Responses include `data_status`: `fresh`, `cached`, or `stale`. A stale response is served only within `WEATHER_CACHE_STALE_SECONDS` after retries fail. Configure retry and cache windows in `.env`.

## Card scoring

Cards are ranked deterministically with persona-specific weights. The current implementation combines precipitation probability, heat, UV, wind, visibility, humidity, and alert presence. Each factor is normalized to `0..1`, multiplied by the persona weight, clamped to `0..1`, and sorted descending.

## Testing

```powershell
pytest
```

Tests use `sample-data/onecall.json` and do not consume OpenWeather quota. Live API checks should be run manually through Postman or an opt-in integration test only.

## User data endpoints

PostgreSQL stores personalization and saved coordinates:

| Method | Endpoint | Purpose |
| --- | --- | --- |
| PUT | `/api/users/{user_id}/preferences` | Create or replace persona preferences |
| GET | `/api/users/{user_id}/preferences` | Read preferences |
| POST | `/api/users/{user_id}/locations` | Save a named location |
| GET | `/api/users/{user_id}/locations` | List saved locations |
| DELETE | `/api/users/{user_id}/locations/{location_id}` | Delete a saved location |

Create the tables with your migration tool or the SQLAlchemy metadata during local development. Authentication is intentionally deferred for the hackathon MVP; `user_id` is currently supplied by the client.

For local development, start PostgreSQL, set `DATABASE_URL`, and run:

```powershell
python -m app.db.init_db
```

The initializer is for development only. Use Alembic migrations before production deployment.

## Postman smoke test

With the server running, call `GET http://127.0.0.1:8000/api/weather/dashboard?lat=13.08&lon=80.27&persona=commuter`. Confirm the response contains `location`, `current`, `forecast`, `alerts`, `cards`, `persona`, `source`, and `fetched_at`.
