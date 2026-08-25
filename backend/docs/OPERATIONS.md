# Operations Guide

## Environment

Copy `.env.example` to `.env` and set:

| Variable | Purpose | Default |
| --- | --- | --- |
| `OPENWEATHER_API_KEY` | Server-side OpenWeather credential | empty |
| `OPENWEATHER_BASE_URL` | OpenWeather API base URL | One Call 4.0 base |
| `OPENWEATHER_TIMEOUT_SECONDS` | Per-attempt provider timeout | `10` |
| `OPENWEATHER_MAX_RETRIES` | Retry count after the first attempt | `2` |
| `WEATHER_CACHE_TTL_SECONDS` | Fresh cache lifetime | `300` |
| `WEATHER_CACHE_STALE_SECONDS` | Maximum stale fallback age | `3600` |
| `DATABASE_URL` | Async PostgreSQL connection string | local `mausam` database |

Never commit `.env` or place API keys in Flutter code.

## Start the backend

```powershell
cd backend
.\.venv\Scripts\Activate.ps1
uvicorn app.main:app --reload
```

## PostgreSQL setup

Create a database named `mausam`, set the correct username/password in `DATABASE_URL`, then initialize local tables:

```powershell
python -m app.db.init_db
```

The initializer uses `create_all` and is for local development. Add Alembic before production schema changes.

## Verification checklist

```powershell
pytest
```

Then verify `/health`, `/docs`, and one dashboard request in Postman. To verify fallback behavior, use a short cache TTL, make one successful request, temporarily use an invalid OpenWeather key, and request the same coordinates before the stale window expires.

## Troubleshooting

- `503 OpenWeather API key is not configured`: set `OPENWEATHER_API_KEY` in `backend/.env` and restart Uvicorn.
- `502 OpenWeather is unavailable`: check network access, base URL, and provider status.
- `504 OpenWeather request timed out`: increase `OPENWEATHER_TIMEOUT_SECONDS` only after checking connectivity.
- `503 Database is unavailable`: check that PostgreSQL is running, the database exists, and `DATABASE_URL` credentials are correct.
- Dashboard shows `data_status=stale`: the provider failed after retries; inspect the warning and restore provider connectivity.

