# API Contract

Base URL during development: `http://127.0.0.1:8000`

The generated contract is available at `/openapi.json`, with interactive views at `/docs` and `/redoc`. The examples below show the stable fields consumed by Flutter.

## Common weather query

Weather endpoints require:

| Parameter | Type | Rules |
| --- | --- | --- |
| `lat` | number | `-90 <= lat <= 90` |
| `lon` | number | `-180 <= lon <= 180` |

## Dashboard

`GET /api/weather/dashboard?lat=13.08&lon=80.27&persona=commuter`

`persona` is one of `fitness`, `traveller`, `health`, or `commuter`; it defaults to `commuter`.

```json
{
  "location": {"latitude": 13.08, "longitude": 80.27, "name": null},
  "current": {
    "temperature_c": 30.0,
    "feels_like_c": 33.0,
    "humidity_pct": 75,
    "pressure_hpa": 1005,
    "wind_speed_kmph": 14.4,
    "visibility_m": 8000,
    "rainfall_1h_mm": 2.4,
    "uv_index": 8.0,
    "weather_code": 500,
    "weather_description": "light rain"
  },
  "forecast": {"hourly": [], "daily": []},
  "alerts": {"items": []},
  "cards": [],
  "recommendations": ["Carry rain protection and allow extra travel time."],
  "persona": "commuter",
  "source": "OpenWeather",
  "fetched_at": "2026-08-25T10:00:00Z",
  "data_status": "fresh",
  "data_warning": null
}
```

`data_status` values:

| Value | Meaning |
| --- | --- |
| `fresh` | Newly fetched from OpenWeather |
| `cached` | Served within the fresh cache TTL |
| `stale` | Provider failed after retries; served from the stale window |

## Weather endpoints

- `GET /api/weather/current` returns the `current` object.
- `GET /api/weather/forecast` returns `hourly` and `daily` arrays.
- `GET /api/weather/alerts` returns `{ "items": [...] }`.

## User data endpoints

The MVP uses `user_id` in the path. Authentication is not implemented yet; do not treat this identifier as authorization.

- `PUT /api/users/{user_id}/preferences`
- `GET /api/users/{user_id}/preferences`
- `POST /api/users/{user_id}/locations`
- `GET /api/users/{user_id}/locations`
- `DELETE /api/users/{user_id}/locations/{location_id}`

### Preferences

`PUT /api/users/demo-user/preferences`

```json
{
  "persona": "fitness",
  "temperature_unit": "celsius",
  "notifications_enabled": true
}
```

### Saved location

`POST /api/users/demo-user/locations`

```json
{"name": "Chennai home", "latitude": 13.08, "longitude": 80.27}
```

## Error contract

FastAPI validation errors return `422`. Provider and infrastructure errors use:

| Status | Meaning |
| --- | --- |
| `502` | OpenWeather unavailable, failed, or returned invalid data |
| `503` | Missing OpenWeather key or PostgreSQL unavailable |
| `504` | OpenWeather request timed out |
| `404` | Requested preference/location does not exist |
| `429` | OpenWeather rate limit was reached |

Errors have the standard shape:

```json
{"detail": "Database is unavailable"}
```
