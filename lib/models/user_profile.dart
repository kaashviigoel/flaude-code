class UserPreferences {
  final String persona;
  final String temperatureUnit; // 'celsius' or 'fahrenheit'
  final bool notificationsEnabled;

  UserPreferences({
    this.persona = 'health',
    this.temperatureUnit = 'celsius',
    this.notificationsEnabled = true,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      persona: json['persona'] as String? ?? 'health',
      temperatureUnit: json['temperature_unit'] as String? ?? 'celsius',
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'persona': persona,
    'temperature_unit': temperatureUnit,
    'notifications_enabled': notificationsEnabled,
  };
}

class SavedLocationModel {
  final int? id;
  final String? userId;
  final String name;
  final double latitude;
  final double longitude;
  final DateTime? createdAt;
  final double? currentTempC;
  final String? condition;
  final String? localTime;

  SavedLocationModel({
    this.id,
    this.userId,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.createdAt,
    this.currentTempC,
    this.condition,
    this.localTime,
  });

  factory SavedLocationModel.fromJson(Map<String, dynamic> json) {
    return SavedLocationModel(
      id: json['id'] as int?,
      userId: json['user_id'] as String?,
      name: json['name'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      currentTempC: (json['current_temp_c'] as num?)?.toDouble(),
      condition: json['condition'] as String?,
      localTime: json['local_time'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
  };
}

class TripModel {
  final String destination;
  final String dateRange;
  final String expectedWeather;
  final int highTemp;
  final int lowTemp;

  TripModel({
    required this.destination,
    required this.dateRange,
    required this.expectedWeather,
    required this.highTemp,
    required this.lowTemp,
  });
}
