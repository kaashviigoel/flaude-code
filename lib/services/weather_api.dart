import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:mausam/models/user_profile.dart';
import 'package:mausam/models/weather.dart';

class WeatherApiService {
  static final WeatherApiService _instance = WeatherApiService._internal();

  factory WeatherApiService() => _instance;

  WeatherApiService._internal();

  Future<Position>? _activeLocationRequest;

  String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }

    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8000';
      }
    } catch (_) {}

    return 'http://127.0.0.1:8000';
  }

  final String defaultUserId = 'demo-user';

  Future<Position> currentPosition() {
    // If Home, Alerts, Persona, etc. are already
    // asking for location, everyone gets the SAME Future.
    if (_activeLocationRequest != null) {
      debugPrint('LOCATION: reusing existing location request');
      return _activeLocationRequest!;
    }

    debugPrint('LOCATION: creating new location request');

    final request = _requestCurrentPosition();

    _activeLocationRequest = request;

    request.whenComplete(() {
      // Only clear it if this is still the active request.
      if (identical(_activeLocationRequest, request)) {
        _activeLocationRequest = null;
      }
    });

    return request;
  }

  Future<Position> _requestCurrentPosition() async {
    debugPrint('========== LOCATION ==========');

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    debugPrint('Location service enabled: $serviceEnabled');

    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();

    debugPrint('Location permission: $permission');

    if (permission == LocationPermission.denied) {
      debugPrint('LOCATION: requesting permission...');

      permission = await Geolocator.requestPermission();

      debugPrint('Location permission after request: $permission');
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission was denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission is permanently denied. '
        'Please enable it in Settings.',
      );
    }

    debugPrint('LOCATION: permission accepted');

    // Important:
    // Do NOT wrap this in another timeout in Home,
    // Alerts or Persona.
    final position =
        await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        ).timeout(
          const Duration(seconds: 20),
          onTimeout: () {
            throw Exception('Unable to determine your current location.');
          },
        );

    debugPrint('========== REAL LOCATION ==========');

    debugPrint('Latitude: ${position.latitude}');

    debugPrint('Longitude: ${position.longitude}');

    debugPrint('Accuracy: ${position.accuracy}');

    debugPrint('===================================');

    return position;
  }

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);

    debugPrint('GET $uri');

    final response = await http
        .get(uri)
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw Exception('Backend request timed out.');
          },
        );

    debugPrint('Response ${response.statusCode}: ${response.body}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Backend returned ${response.statusCode}: ${response.body}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<DashboardResponse> fetchDashboard({
    required double lat,
    required double lon,
    String persona = 'commuter',
  }) async {
    final data = await _get(
      '/api/weather/dashboard',
      query: {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'persona': persona.toLowerCase(),
      },
    );

    return DashboardResponse.fromJson(data);
  }

  Future<WeatherNow> fetchCurrent({
    required double lat,
    required double lon,
  }) async {
    final data = await _get(
      '/api/weather/current',
      query: {'lat': lat.toString(), 'lon': lon.toString()},
    );

    return WeatherNow.fromJson(data);
  }

  Future<WeatherForecast> fetchForecast({
    required double lat,
    required double lon,
  }) async {
    final data = await _get(
      '/api/weather/forecast',
      query: {'lat': lat.toString(), 'lon': lon.toString()},
    );

    return WeatherForecast.fromJson(data);
  }

  Future<WeatherAlerts> fetchAlerts({
    required double lat,
    required double lon,
  }) async {
    final data = await _get(
      '/api/weather/alerts',
      query: {'lat': lat.toString(), 'lon': lon.toString()},
    );

    return WeatherAlerts.fromJson(data);
  }

  Future<UserPreferences> fetchPreferences(String id) async {
    final data = await _get('/api/users/$id/preferences');

    return UserPreferences.fromJson(data);
  }

  Future<bool> savePreferences(String id, UserPreferences preferences) async {
    final response = await http
        .put(
          Uri.parse('$baseUrl/api/users/$id/preferences'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(preferences.toJson()),
        )
        .timeout(const Duration(seconds: 15));

    return response.statusCode == 200;
  }

  Future<List<SavedLocationModel>> fetchSavedLocations(String id) async {
    final response = await http
        .get(Uri.parse('$baseUrl/api/users/$id/locations'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Backend returned ${response.statusCode}: ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as List;

    return data
        .map(
          (item) => SavedLocationModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  Future<SavedLocationModel?> addSavedLocation(
    String id,
    String name,
    double lat,
    double lon,
  ) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/users/$id/locations'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'name': name, 'latitude': lat, 'longitude': lon}),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 201) {
      throw Exception(
        'Backend returned ${response.statusCode}: ${response.body}',
      );
    }

    return SavedLocationModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<bool> deleteSavedLocation(String id, int locationId) async {
    final response = await http
        .delete(Uri.parse('$baseUrl/api/users/$id/locations/$locationId'))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 204) {
      return true;
    }

    throw Exception(
      'Backend returned ${response.statusCode}: ${response.body}',
    );
  }
}
