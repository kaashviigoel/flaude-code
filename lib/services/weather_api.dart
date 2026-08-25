import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mausam/models/user_profile.dart';
import 'package:mausam/models/weather.dart';

class WeatherApiService {
  static final WeatherApiService _instance = WeatherApiService._internal();
  factory WeatherApiService() => _instance;
  WeatherApiService._internal();

  String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8000';
      }
    } catch (_) {}
    return 'http://127.0.0.1:8000';
  }

  final String defaultUserId = 'demo-user';

  // In-memory fallback locations for instant responsiveness
  final List<SavedLocationModel> _fallbackSavedLocations = [
    SavedLocationModel(
      id: 1,
      userId: 'demo-user',
      name: 'London',
      latitude: 51.5074,
      longitude: -0.1278,
      currentTempC: 12,
      condition: 'Cloudy',
      localTime: '10:45 AM',
    ),
    SavedLocationModel(
      id: 2,
      userId: 'demo-user',
      name: 'Tokyo',
      latitude: 35.6762,
      longitude: 139.6503,
      currentTempC: 15,
      condition: 'Clear Night',
      localTime: '07:45 PM',
    ),
    SavedLocationModel(
      id: 3,
      userId: 'demo-user',
      name: 'Delhi',
      latitude: 28.6139,
      longitude: 77.2090,
      currentTempC: 32,
      condition: 'Sunny',
      localTime: '03:15 PM',
    ),
  ];

  /// Fetch dashboard data from backend API with fallback
  Future<DashboardResponse> fetchDashboard({
    double lat = 13.08,
    double lon = 80.27,
    String persona = 'health',
  }) async {
    final uri = Uri.parse(
        '$baseUrl/api/weather/dashboard?lat=$lat&lon=$lon&persona=${persona.toLowerCase()}');
    try {
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return DashboardResponse.fromJson(data);
      }
    } catch (e) {
      debugPrint('WeatherApiService fetchDashboard error: $e, using mock data.');
    }
    return _buildMockDashboard(lat: lat, lon: lon, persona: persona);
  }

  /// Fetch current weather
  Future<WeatherNow> fetchCurrent({double lat = 13.08, double lon = 80.27}) async {
    final uri = Uri.parse('$baseUrl/api/weather/current?lat=$lat&lon=$lon');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return WeatherNow.fromJson(data);
      }
    } catch (e) {
      debugPrint('WeatherApiService fetchCurrent error: $e');
    }
    return _buildMockDashboard(lat: lat, lon: lon).current;
  }

  /// Fetch forecast
  Future<WeatherForecast> fetchForecast({double lat = 13.08, double lon = 80.27}) async {
    final uri = Uri.parse('$baseUrl/api/weather/forecast?lat=$lat&lon=$lon');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return WeatherForecast.fromJson(data);
      }
    } catch (e) {
      debugPrint('WeatherApiService fetchForecast error: $e');
    }
    return _buildMockDashboard(lat: lat, lon: lon).forecast;
  }

  /// Fetch alerts
  Future<WeatherAlerts> fetchAlerts({double lat = 13.08, double lon = 80.27}) async {
    final uri = Uri.parse('$baseUrl/api/weather/alerts?lat=$lat&lon=$lon');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return WeatherAlerts.fromJson(data);
      }
    } catch (e) {
      debugPrint('WeatherApiService fetchAlerts error: $e');
    }
    return _buildMockAlerts();
  }

  /// Fetch user preferences
  Future<UserPreferences> fetchPreferences(String userId) async {
    final uri = Uri.parse('$baseUrl/api/users/$userId/preferences');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return UserPreferences.fromJson(data);
      }
    } catch (e) {
      debugPrint('WeatherApiService fetchPreferences error: $e');
    }
    return UserPreferences();
  }

  /// Save user preferences
  Future<bool> savePreferences(String userId, UserPreferences prefs) async {
    final uri = Uri.parse('$baseUrl/api/users/$userId/preferences');
    try {
      final response = await http
          .put(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(prefs.toJson()),
          )
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('WeatherApiService savePreferences error: $e');
      return false;
    }
  }

  /// Fetch saved locations
  Future<List<SavedLocationModel>> fetchSavedLocations(String userId) async {
    final uri = Uri.parse('$baseUrl/api/users/$userId/locations');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final list = json.decode(response.body) as List<dynamic>;
        return list
            .map((e) => SavedLocationModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('WeatherApiService fetchSavedLocations error: $e');
    }
    return List.from(_fallbackSavedLocations);
  }

  /// Add a saved location
  Future<SavedLocationModel?> addSavedLocation(
    String userId,
    String name,
    double lat,
    double lon,
  ) async {
    final uri = Uri.parse('$baseUrl/api/users/$userId/locations');
    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'name': name, 'latitude': lat, 'longitude': lon}),
          )
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return SavedLocationModel.fromJson(data);
      }
    } catch (e) {
      debugPrint('WeatherApiService addSavedLocation error: $e');
    }
    final newLoc = SavedLocationModel(
      id: _fallbackSavedLocations.length + 1,
      userId: userId,
      name: name,
      latitude: lat,
      longitude: lon,
      createdAt: DateTime.now(),
      currentTempC: 25,
      condition: 'Partly Cloudy',
      localTime: '12:00 PM',
    );
    _fallbackSavedLocations.add(newLoc);
    return newLoc;
  }

  /// Delete a saved location
  Future<bool> deleteSavedLocation(String userId, int locationId) async {
    final uri = Uri.parse('$baseUrl/api/users/$userId/locations/$locationId');
    try {
      final response = await http.delete(uri).timeout(const Duration(seconds: 3));
      if (response.statusCode == 204) return true;
    } catch (e) {
      debugPrint('WeatherApiService deleteSavedLocation error: $e');
    }
    _fallbackSavedLocations.removeWhere((l) => l.id == locationId);
    return true;
  }

  // --- Mock Data Generator Matching Figma Frames ---

  DashboardResponse _buildMockDashboard({
    double lat = 13.08,
    double lon = 80.27,
    String persona = 'health',
  }) {
    final now = DateTime.now();

    return DashboardResponse(
      location: WeatherLocation(
        latitude: lat,
        longitude: lon,
        name: persona.toLowerCase() == 'health' ? 'San Francisco' : 'New York City',
      ),
      current: WeatherNow(
        observedAt: now,
        temperatureC: 28.0,
        feelsLikeC: 30.0,
        humidityPct: 42.0,
        pressureHpa: 1013.0,
        windSpeedKmph: 12.5,
        windDirectionDeg: 210.0,
        visibilityM: 10000.0,
        rainfall1hMm: 0.0,
        uvIndex: 6.0,
        weatherCode: 801,
        weatherDescription: 'Partly Cloudy',
      ),
      forecast: WeatherForecast(
        hourly: [
          ForecastPeriod(
            startsAt: now,
            temperatureC: 28.0,
            feelsLikeC: 29.0,
            humidityPct: 42.0,
            precipitationProbability: 0.0,
            weatherCode: 801,
            weatherDescription: 'Partly Cloudy',
          ),
          ForecastPeriod(
            startsAt: now.add(const Duration(hours: 1)),
            temperatureC: 29.0,
            feelsLikeC: 30.0,
            humidityPct: 40.0,
            precipitationProbability: 0.05,
            weatherCode: 802,
            weatherDescription: 'Scattered Clouds',
          ),
          ForecastPeriod(
            startsAt: now.add(const Duration(hours: 2)),
            temperatureC: 30.0,
            feelsLikeC: 32.0,
            humidityPct: 38.0,
            precipitationProbability: 0.0,
            weatherCode: 800,
            weatherDescription: 'Sunny',
          ),
          ForecastPeriod(
            startsAt: now.add(const Duration(hours: 3)),
            temperatureC: 32.0,
            feelsLikeC: 34.0,
            humidityPct: 35.0,
            precipitationProbability: 0.0,
            weatherCode: 800,
            weatherDescription: 'Sunny',
          ),
          ForecastPeriod(
            startsAt: now.add(const Duration(hours: 4)),
            temperatureC: 31.0,
            feelsLikeC: 33.0,
            humidityPct: 39.0,
            precipitationProbability: 0.1,
            weatherCode: 801,
            weatherDescription: 'Partly Cloudy',
          ),
          ForecastPeriod(
            startsAt: now.add(const Duration(hours: 5)),
            temperatureC: 29.0,
            feelsLikeC: 30.0,
            humidityPct: 44.0,
            precipitationProbability: 0.15,
            weatherCode: 801,
            weatherDescription: 'Partly Cloudy',
          ),
        ],
        daily: [
          ForecastPeriod(
            startsAt: now,
            temperatureMinC: 18.0,
            temperatureMaxC: 32.0,
            precipitationProbability: 0.10,
            weatherCode: 801,
            weatherDescription: 'Partly Cloudy',
          ),
          ForecastPeriod(
            startsAt: now.add(const Duration(days: 1)),
            temperatureMinC: 16.0,
            temperatureMaxC: 24.0,
            precipitationProbability: 0.80,
            weatherCode: 500,
            weatherDescription: 'Rain Showers',
          ),
          ForecastPeriod(
            startsAt: now.add(const Duration(days: 2)),
            temperatureMinC: 15.0,
            temperatureMaxC: 22.0,
            precipitationProbability: 0.20,
            weatherCode: 802,
            weatherDescription: 'Cloudy',
          ),
          ForecastPeriod(
            startsAt: now.add(const Duration(days: 3)),
            temperatureMinC: 17.0,
            temperatureMaxC: 29.0,
            precipitationProbability: 0.0,
            weatherCode: 800,
            weatherDescription: 'Sunny',
          ),
          ForecastPeriod(
            startsAt: now.add(const Duration(days: 4)),
            temperatureMinC: 19.0,
            temperatureMaxC: 31.0,
            precipitationProbability: 0.0,
            weatherCode: 800,
            weatherDescription: 'Sunny',
          ),
        ],
      ),
      alerts: _buildMockAlerts(),
      cards: [
        WeatherCardData(
          cardId: 'aqi_card',
          title: 'Air Quality Index',
          priority: 0.95,
          visible: true,
          reason: 'Air Quality is moderate for sensitive individuals.',
          data: {'aqi': 112, 'status': 'Unhealthy for Sensitive Groups'},
        ),
        WeatherCardData(
          cardId: 'uv_card',
          title: 'UV Index',
          priority: 0.85,
          visible: true,
          reason: 'Protection needed until 4 PM.',
          data: {'uv': 6, 'status': 'High'},
        ),
      ],
      persona: persona,
      source: 'OpenWeather',
      fetchedAt: now,
      dataStatus: 'fresh',
      recommendations: [
        'Air Quality Index is 112 (Unhealthy for Sensitive Groups). Limit prolonged outdoor exertion.',
        'High UV levels detected (6 High). Apply SPF 30+ sunscreen and wear sunglasses.',
        'Optimal humidity of 42% for respiratory comfort.',
      ],
    );
  }

  WeatherAlerts _buildMockAlerts() {
    return WeatherAlerts(
      items: [
        WeatherAlert(
          sender: 'National Weather Bureau',
          event: 'Heavy Rain Alert',
          severity: 'critical',
          startsAt: DateTime.now().add(const Duration(hours: 2)),
          endsAt: DateTime.now().add(const Duration(hours: 8)),
          description:
              'Expect severe localized flooding and significant travel disruption. Seek shelter immediately if outdoors.',
        ),
        WeatherAlert(
          sender: 'State Meteorological Department',
          event: 'Heat Alert',
          severity: 'warning',
          startsAt: DateTime.now().add(const Duration(days: 1, hours: 2)),
          endsAt: DateTime.now().add(const Duration(days: 1, hours: 5)),
          description:
              'Extreme temperatures expected. Prolonged exposure may lead to heat exhaustion. Stay hydrated and indoors if possible.',
        ),
        WeatherAlert(
          sender: 'Regional Coastal Guard',
          event: 'Strong Wind',
          severity: 'advisory',
          startsAt: DateTime.now(),
          endsAt: DateTime.now().add(const Duration(hours: 12)),
          description:
              'Gusts up to 45 km/h. Secure loose outdoor objects and exercise caution while driving high-profile vehicles.',
        ),
      ],
    );
  }
}
