# Postman Workflow

## Environment variables

Create a Postman environment with:

```text
base_url = http://127.0.0.1:8000
lat = 13.08
lon = 80.27
user_id = demo-user
```

## Requests

1. `GET {{base_url}}/health`
2. `GET {{base_url}}/api/weather/current?lat={{lat}}&lon={{lon}}`
3. `GET {{base_url}}/api/weather/forecast?lat={{lat}}&lon={{lon}}`
4. `GET {{base_url}}/api/weather/alerts?lat={{lat}}&lon={{lon}}`
5. `GET {{base_url}}/api/weather/dashboard?lat={{lat}}&lon={{lon}}&persona=fitness`
6. `PUT {{base_url}}/api/users/{{user_id}}/preferences`
7. `POST {{base_url}}/api/users/{{user_id}}/locations`
8. `GET {{base_url}}/api/users/{{user_id}}/locations`

Use `Content-Type: application/json` for `PUT` and `POST` requests. The database requests require PostgreSQL to be running and configured.

## Assertions

For a successful dashboard response, verify `source == OpenWeather`, `persona` matches the query, `cards` is an array, and `data_status` is one of `fresh`, `cached`, or `stale`.

