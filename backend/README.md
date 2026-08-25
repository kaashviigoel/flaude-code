Mausam Personalized Homepage

An adaptive personalization layer for the Mausam mobile application, developed for Smart India Hackathon 2026 – Problem Statement PS26076.

The application aims to make weather information more relevant to each user by dynamically prioritizing weather insights based on the user's persona, location, time/context, and live weather conditions.

Problem Statement

PS26076 — Personalized Homepage for Mausam Mobile Application

Traditional weather applications expose large amounts of information to users, even when much of it may not be relevant to their immediate needs. This project proposes a personalized homepage that determines what weather information should be prioritized, rather than only changing its visual presentation.

Proposed Solution

The system uses an adaptive personalization layer that considers:

User Persona — fitness, commuter, traveler, health, family, agriculture, beach, and events

Location — current and saved locations

Time & Context — morning/evening, weekday/weekend, and upcoming activities

Live Weather — IMD weather data, forecasts, and warnings

The personalization engine converts raw weather information into context-aware recommendations and prioritizes the information most useful to the user.

Key Features

Personalized weather homepage

Persona-based information prioritization

Current and saved location support

Context-aware weather recommendations

Live weather and forecast integration

Weather warning prioritization

Modular weather-card architecture

Normalized weather-data model

API caching and graceful fallback

Continuous personalization based on user interaction and feedback

Technology Stack

Layer

Technology

Purpose

Mobile App

Flutter / Dart

Cross-platform Android application and UI

UI

Material UI

Mobile interface and reusable components

API Client

HTTP

REST API communication from Flutter

Backend

Python / FastAPI

RESTful API and application logic

Recommendation Engine

Python

Personalization and context-aware scoring

Database

PostgreSQL

User profiles, preferences, persona weights, saved locations, and configuration

Weather Data

IMD APIs

Current weather, forecasts, warnings, and applicable marine/agromet data

System Architecture

                    ┌─────────────────────────┐
                    │   India Meteorological  │
                    │      Department (IMD)   │
                    │  Weather / Forecast /    │
                    │       Warnings           │
                    └────────────┬────────────┘
                                 │
                                 ▼
                    ┌─────────────────────────┐
                    │       FastAPI Backend    │
                    │                         │
                    │  • REST API             │
                    │  • Data Normalization   │
                    │  • Personalization      │
                    │  • Recommendation Engine│
                    └────────────┬────────────┘
                                 │
                       ┌─────────┴─────────┐
                       ▼                   ▼
              ┌────────────────┐   ┌────────────────┐
              │   PostgreSQL   │   │ Normalized     │
              │                │   │ Weather Data   │
              │ • Profiles     │   └───────┬────────┘
              │ • Preferences  │           │
              │ • Persona      │           │
              │   weights      │           │
              │ • Locations    │           │
              └────────────────┘           │
                                           ▼
                              ┌─────────────────────────┐
                              │      Flutter App        │
                              │                         │
                              │  • Personalized Home   │
                              │  • Weather Cards       │
                              │  • Recommendations     │
                              │  • Alerts / Warnings   │
                              └─────────────────────────┘

Flutter Application

The mobile application is built using Flutter with Dart.

Flutter is responsible for:

Rendering the personalized homepage.

Displaying weather information through reusable UI cards.

Managing user interaction and preferences.

Requesting data from the FastAPI backend through REST APIs.

Displaying recommendations according to the backend's prioritization.

Supporting a modular UI so new weather-information cards can be added without redesigning the entire homepage.

Suggested Flutter Structure

lib/
├── main.dart
│
├── core/
│   ├── constants/
│   ├── theme/
│   └── network/
│
├── models/
│   ├── weather.dart
│   ├── user_profile.dart
│   ├── location.dart
│   └── recommendation.dart
│
├── services/
│   ├── api_service.dart
│   └── weather_service.dart
│
├── screens/
│   ├── home/
│   ├── onboarding/
│   ├── locations/
│   └── settings/
│
├── widgets/
│   ├── weather_card.dart
│   ├── recommendation_card.dart
│   ├── warning_card.dart
│   └── location_selector.dart
│
└── state/
    └── ...

The structure above is a recommended organization for the Flutter implementation and can be adapted to the actual repository structure.

Personalization Logic

The backend combines user and environmental context to determine which information should receive higher priority.

A conceptual relevance score can be represented as:

Relevance Score =
    Persona Weight
  + Location Relevance
  + Time/Context Relevance
  + Weather Severity
  + User Interaction Signals

The exact scoring implementation can evolve independently of the Flutter UI because the personalization logic is handled in the backend.

Example

A commuter may receive:

Rain/storm warnings

Current temperature

Visibility or severe-weather information

Forecast for commuting hours

A traveler may instead receive:

Forecast for the destination

Weather warnings

Temperature and precipitation

Upcoming weather changes

This allows the same underlying weather data to produce different homepage priorities for different users.

Backend

The backend uses Python and FastAPI to provide a RESTful API layer between the Flutter application, personalization engine, database, and external weather-data sources.

Responsibilities include:

Fetching and processing weather information

Normalizing external weather data

Managing user preferences

Applying persona weights

Calculating contextual relevance

Generating recommendations

Handling API failures and fallbacks

Providing normalized JSON responses to the Flutter application

Database

PostgreSQL stores persistent personalization information, including:

User profiles

User preferences

Persona weights

Saved locations

Personalization configuration

The database is intentionally separated from the presentation layer so that personalization rules can evolve without requiring major Flutter-side changes.

Data Flow

User
  │
  ▼
Flutter App
  │
  │ REST API
  ▼
FastAPI Backend
  │
  ├──────────────► PostgreSQL
  │                 │
  │                 └── User preferences,
  │                     persona weights,
  │                     saved locations
  │
  └──────────────► IMD Weather APIs
                    │
                    └── Weather / Forecast /
                        Warnings / Applicable Data
                              │
                              ▼
                       Data Normalization
                              │
                              ▼
                    Personalization Engine
                              │
                              ▼
                     Relevance Prioritization
                              │
                              ▼
                        JSON Response
                              │
                              ▼
                        Flutter Homepage

Handling Challenges

The proposed architecture addresses the major challenges identified for the solution:

Challenge

Approach

Large volume of weather information

Relevance-based prioritization

Rapidly changing conditions

Context-aware scoring

API availability/rate limits

Caching and graceful fallback

Missing/inconsistent data

Normalized data layer

Maintaining relevant recommendations

User interaction and feedback

Information overload

Show only the most useful insights

Future feature expansion

Modular card architecture

Feasibility

The MVP does not require building an independent weather-prediction system. It can leverage existing IMD weather-data infrastructure and focus on personalization, prioritization, and presentation.

Flutter also provides a scalable cross-platform development approach, while a normalized backend data layer isolates the application from differences in external API formats.

Impact

The personalized homepage is intended to:

Reduce cognitive overload from excessive weather information

Surface the information most relevant to each user

Provide actionable, context-aware recommendations

Improve awareness of weather-related risks

Enable faster day-to-day decisions

Potential Application Areas

Personal health and outdoor activity planning

Daily commuting and mobility

Travel planning

Weather-aware family activities

Agriculture and outdoor operations

Marine and recreational activities

Event and activity planning

Getting Started

Prerequisites

Install the following before running the project:

Flutter SDK

Dart SDK (included with Flutter)

Android Studio or another Flutter-compatible IDE

Python 3.x

PostgreSQL

Access/configuration for the required weather-data APIs

Verify Flutter installation:

flutter doctor

Run the Flutter Application

flutter pub get
flutter run

For an Android build:

flutter build apk

Backend Setup

Create and activate a Python virtual environment:

python -m venv .venv

Activate it on macOS/Linux:

source .venv/bin/activate

On Windows:

.venv\Scripts\activate

Install backend dependencies:

pip install -r requirements.txt

Start the FastAPI server using the project's configured application entry point.

Configure API credentials, database connection details, and environment variables according to the actual backend implementation. Do not commit secrets to the repository.

Development Principles

Keep Flutter UI components modular and reusable.

Keep weather-data normalization in the backend.

Keep personalization logic separate from presentation logic.

Use a consistent internal weather-data schema.

Cache external data where appropriate.

Provide graceful fallback behavior when external APIs are unavailable.

Keep recommendation logic extensible so additional personas and signals can be introduced later.

Research & References

The project is based on the Smart India Hackathon 2026 Problem Statement PS26076 — Personalized Homepage for Mausam Mobile Application and references the India Meteorological Department (IMD), Flutter/Dart, FastAPI, PostgreSQL, REST API, and JSON architecture.

Project Status

Hackathon Prototype / MVP

The repository can be extended with additional personas, recommendation signals, UI cards, and personalization strategies as the implementation evolves.

Team

Team: FLAUDE CODE
Event: Smart India Hackathon 2026
Problem Statement: PS26076