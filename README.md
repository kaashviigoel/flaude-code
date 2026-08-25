# MausamSense

Context-aware weather personalization for the Mausam mobile application.

The repository contains the Flutter client and an OpenWeather-backed FastAPI service. Backend documentation starts at [`backend/README.md`](backend/README.md).

## Project areas

- `lib/`: Flutter application
- `backend/`: FastAPI API, normalization, resilience, personalization, and PostgreSQL persistence
- `backend/docs/`: architecture, API contract, scoring, operations, and Postman guides

## Backend quick start

```powershell
cd backend
.\.venv\Scripts\Activate.ps1
uvicorn app.main:app --reload
```

Open the API documentation at `http://127.0.0.1:8000/docs`.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
