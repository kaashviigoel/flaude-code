import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:mausam/models/user_profile.dart';
import 'package:mausam/models/weather.dart';

class WeatherApiService {
  static final WeatherApiService _instance = WeatherApiService._internal();
  factory WeatherApiService() => _instance;
  WeatherApiService._internal();
  String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    } catch (_) {}
    return 'http://127.0.0.1:8000';
  }

  final String defaultUserId = 'demo-user';
  Future<Position> currentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Location services are disabled');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission is required');
    }
    return Geolocator.getCurrentPosition();
  }

  Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, String>? query,
  }) async {
    final r = await http
        .get(Uri.parse('$baseUrl$path').replace(queryParameters: query))
        .timeout(const Duration(seconds: 12));
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('Backend returned ${r.statusCode}: ${r.body}');
    }
    return jsonDecode(r.body) as Map<String, dynamic>;
  }

  Future<DashboardResponse> fetchDashboard({
    required double lat,
    required double lon,
    String persona = 'commuter',
  }) async => DashboardResponse.fromJson(
    await _get(
      '/api/weather/dashboard',
      query: {'lat': '$lat', 'lon': '$lon', 'persona': persona.toLowerCase()},
    ),
  );
  Future<WeatherNow> fetchCurrent({
    required double lat,
    required double lon,
  }) async => WeatherNow.fromJson(
    await _get('/api/weather/current', query: {'lat': '$lat', 'lon': '$lon'}),
  );
  Future<WeatherForecast> fetchForecast({
    required double lat,
    required double lon,
  }) async => WeatherForecast.fromJson(
    await _get('/api/weather/forecast', query: {'lat': '$lat', 'lon': '$lon'}),
  );
  Future<WeatherAlerts> fetchAlerts({
    required double lat,
    required double lon,
  }) async => WeatherAlerts.fromJson(
    await _get('/api/weather/alerts', query: {'lat': '$lat', 'lon': '$lon'}),
  );
  Future<UserPreferences> fetchPreferences(String id) async =>
      UserPreferences.fromJson(await _get('/api/users/$id/preferences'));
  Future<bool> savePreferences(String id, UserPreferences p) async {
    final r = await http
        .put(
          Uri.parse('$baseUrl/api/users/$id/preferences'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(p.toJson()),
        )
        .timeout(const Duration(seconds: 12));
    return r.statusCode == 200;
  }

  Future<List<SavedLocationModel>> fetchSavedLocations(String id) async {
    final r = await http
        .get(Uri.parse('$baseUrl/api/users/$id/locations'))
        .timeout(const Duration(seconds: 12));
    if (r.statusCode != 200) {
      throw Exception('Backend returned ${r.statusCode}');
    }
    return (jsonDecode(r.body) as List)
        .map((e) => SavedLocationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SavedLocationModel?> addSavedLocation(
    String id,
    String name,
    double lat,
    double lon,
  ) async {
    final r = await http
        .post(
          Uri.parse('$baseUrl/api/users/$id/locations'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'name': name, 'latitude': lat, 'longitude': lon}),
        )
        .timeout(const Duration(seconds: 12));
    if (r.statusCode != 201) {
      throw Exception('Backend returned ${r.statusCode}');
    }
    return SavedLocationModel.fromJson(
      jsonDecode(r.body) as Map<String, dynamic>,
    );
  }

  Future<bool> deleteSavedLocation(String id, int locationId) async {
    final r = await http
        .delete(Uri.parse('$baseUrl/api/users/$id/locations/$locationId'))
        .timeout(const Duration(seconds: 12));
    if (r.statusCode == 204) return true;
    throw Exception('Backend returned ${r.statusCode}');
  }
}
