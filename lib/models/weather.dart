class WeatherLocation {
  final double latitude;
  final double longitude;
  final String? name;

  WeatherLocation({required this.latitude, required this.longitude, this.name});

  factory WeatherLocation.fromJson(Map<String, dynamic> json) {
    return WeatherLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'name': name,
  };
}

class WeatherNow {
  final DateTime? observedAt;
  final double? temperatureC;
  final double? feelsLikeC;
  final double? humidityPct;
  final double? pressureHpa;
  final double? windSpeedKmph;
  final double? windDirectionDeg;
  final double? visibilityM;
  final double? rainfall1hMm;
  final double? uvIndex;
  final int? weatherCode;
  final String? weatherDescription;

  WeatherNow({
    this.observedAt,
    this.temperatureC,
    this.feelsLikeC,
    this.humidityPct,
    this.pressureHpa,
    this.windSpeedKmph,
    this.windDirectionDeg,
    this.visibilityM,
    this.rainfall1hMm,
    this.uvIndex,
    this.weatherCode,
    this.weatherDescription,
  });

  factory WeatherNow.fromJson(Map<String, dynamic> json) {
    return WeatherNow(
      observedAt: json['observed_at'] != null
          ? DateTime.tryParse(json['observed_at'] as String)
          : null,
      temperatureC: (json['temperature_c'] as num?)?.toDouble(),
      feelsLikeC: (json['feels_like_c'] as num?)?.toDouble(),
      humidityPct: (json['humidity_pct'] as num?)?.toDouble(),
      pressureHpa: (json['pressure_hpa'] as num?)?.toDouble(),
      windSpeedKmph: (json['wind_speed_kmph'] as num?)?.toDouble(),
      windDirectionDeg: (json['wind_direction_deg'] as num?)?.toDouble(),
      visibilityM: (json['visibility_m'] as num?)?.toDouble(),
      rainfall1hMm: (json['rainfall_1h_mm'] as num?)?.toDouble(),
      uvIndex: (json['uv_index'] as num?)?.toDouble(),
      weatherCode: json['weather_code'] as int?,
      weatherDescription: json['weather_description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'observed_at': observedAt?.toIso8601String(),
    'temperature_c': temperatureC,
    'feels_like_c': feelsLikeC,
    'humidity_pct': humidityPct,
    'pressure_hpa': pressureHpa,
    'wind_speed_kmph': windSpeedKmph,
    'wind_direction_deg': windDirectionDeg,
    'visibility_m': visibilityM,
    'rainfall_1h_mm': rainfall1hMm,
    'uv_index': uvIndex,
    'weather_code': weatherCode,
    'weather_description': weatherDescription,
  };
}

class ForecastPeriod {
  final DateTime? startsAt;
  final double? temperatureC;
  final double? temperatureMinC;
  final double? temperatureMaxC;
  final double? feelsLikeC;
  final double? humidityPct;
  final double? precipitationProbability;
  final double? rainfallMm;
  final double? windSpeedKmph;
  final int? weatherCode;
  final String? weatherDescription;

  ForecastPeriod({
    this.startsAt,
    this.temperatureC,
    this.temperatureMinC,
    this.temperatureMaxC,
    this.feelsLikeC,
    this.humidityPct,
    this.precipitationProbability,
    this.rainfallMm,
    this.windSpeedKmph,
    this.weatherCode,
    this.weatherDescription,
  });

  factory ForecastPeriod.fromJson(Map<String, dynamic> json) {
    return ForecastPeriod(
      startsAt: json['starts_at'] != null
          ? DateTime.tryParse(json['starts_at'] as String)
          : null,
      temperatureC: (json['temperature_c'] as num?)?.toDouble(),
      temperatureMinC: (json['temperature_min_c'] as num?)?.toDouble(),
      temperatureMaxC: (json['temperature_max_c'] as num?)?.toDouble(),
      feelsLikeC: (json['feels_like_c'] as num?)?.toDouble(),
      humidityPct: (json['humidity_pct'] as num?)?.toDouble(),
      precipitationProbability: (json['precipitation_probability'] as num?)
          ?.toDouble(),
      rainfallMm: (json['rainfall_mm'] as num?)?.toDouble(),
      windSpeedKmph: (json['wind_speed_kmph'] as num?)?.toDouble(),
      weatherCode: json['weather_code'] as int?,
      weatherDescription: json['weather_description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'starts_at': startsAt?.toIso8601String(),
    'temperature_c': temperatureC,
    'temperature_min_c': temperatureMinC,
    'temperature_max_c': temperatureMaxC,
    'feels_like_c': feelsLikeC,
    'humidity_pct': humidityPct,
    'precipitation_probability': precipitationProbability,
    'rainfall_mm': rainfallMm,
    'wind_speed_kmph': windSpeedKmph,
    'weather_code': weatherCode,
    'weather_description': weatherDescription,
  };
}

class WeatherForecast {
  final List<ForecastPeriod> hourly;
  final List<ForecastPeriod> daily;

  WeatherForecast({this.hourly = const [], this.daily = const []});

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    return WeatherForecast(
      hourly:
          (json['hourly'] as List<dynamic>?)
              ?.map((e) => ForecastPeriod.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      daily:
          (json['daily'] as List<dynamic>?)
              ?.map((e) => ForecastPeriod.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'hourly': hourly.map((e) => e.toJson()).toList(),
    'daily': daily.map((e) => e.toJson()).toList(),
  };
}

class WeatherAlert {
  final String? sender;
  final String? event;
  final String? severity; // e.g. "critical", "warning", "advisory"
  final DateTime? startsAt;
  final DateTime? endsAt;
  final String? description;

  WeatherAlert({
    this.sender,
    this.event,
    this.severity,
    this.startsAt,
    this.endsAt,
    this.description,
  });

  factory WeatherAlert.fromJson(Map<String, dynamic> json) {
    return WeatherAlert(
      sender: json['sender'] as String?,
      event: json['event'] as String?,
      severity: json['severity'] as String?,
      startsAt: json['starts_at'] != null
          ? DateTime.tryParse(json['starts_at'] as String)
          : null,
      endsAt: json['ends_at'] != null
          ? DateTime.tryParse(json['ends_at'] as String)
          : null,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'sender': sender,
    'event': event,
    'severity': severity,
    'starts_at': startsAt?.toIso8601String(),
    'ends_at': endsAt?.toIso8601String(),
    'description': description,
  };
}

class WeatherAlerts {
  final List<WeatherAlert> items;

  WeatherAlerts({this.items = const []});

  factory WeatherAlerts.fromJson(Map<String, dynamic> json) {
    return WeatherAlerts(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => WeatherAlert.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
  };
}

class WeatherCardData {
  final String cardId;
  final String title;
  final double priority;
  final bool visible;
  final String reason;
  final Map<String, dynamic> data;

  WeatherCardData({
    required this.cardId,
    required this.title,
    required this.priority,
    required this.visible,
    required this.reason,
    this.data = const {},
  });

  factory WeatherCardData.fromJson(Map<String, dynamic> json) {
    return WeatherCardData(
      cardId: json['card_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      priority: (json['priority'] as num?)?.toDouble() ?? 0.0,
      visible: json['visible'] as bool? ?? true,
      reason: json['reason'] as String? ?? '',
      data: json['data'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
    'card_id': cardId,
    'title': title,
    'priority': priority,
    'visible': visible,
    'reason': reason,
    'data': data,
  };
}

class DashboardResponse {
  final WeatherLocation location;
  final WeatherNow current;
  final WeatherForecast forecast;
  final WeatherAlerts alerts;
  final List<WeatherCardData> cards;
  final String persona;
  final String source;
  final DateTime fetchedAt;
  final String dataStatus;
  final String? dataWarning;
  final List<String> recommendations;

  DashboardResponse({
    required this.location,
    required this.current,
    required this.forecast,
    required this.alerts,
    this.cards = const [],
    required this.persona,
    this.source = 'OpenWeather',
    required this.fetchedAt,
    this.dataStatus = 'fresh',
    this.dataWarning,
    this.recommendations = const [],
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      location: WeatherLocation.fromJson(
        json['location'] as Map<String, dynamic>? ??
            {'latitude': 0.0, 'longitude': 0.0},
      ),
      current: WeatherNow.fromJson(
        json['current'] as Map<String, dynamic>? ?? {},
      ),
      forecast: WeatherForecast.fromJson(
        json['forecast'] as Map<String, dynamic>? ?? {},
      ),
      alerts: WeatherAlerts.fromJson(
        json['alerts'] as Map<String, dynamic>? ?? {},
      ),
      cards:
          (json['cards'] as List<dynamic>?)
              ?.map((e) => WeatherCardData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      persona: json['persona'] as String? ?? 'commuter',
      source: json['source'] as String? ?? 'OpenWeather',
      fetchedAt: json['fetched_at'] != null
          ? DateTime.tryParse(json['fetched_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      dataStatus: json['data_status'] as String? ?? 'fresh',
      dataWarning: json['data_warning'] as String?,
      recommendations:
          (json['recommendations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
