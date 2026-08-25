from fastapi import FastAPI

from app.api.routes import router

app = FastAPI(
    title="MausamSense Weather API",
    description=(
        "OpenWeather-backed weather normalization and context-aware card ranking "
        "service for the MausamSense Flutter application."
    ),
    version="0.1.0",
)
app.include_router(router)

