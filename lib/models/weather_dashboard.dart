class WeatherDashboard {
  final String persona, location, description, dataStatus;
  final double? temperature, feelsLike;
  final int? humidity;
  final List<String> recommendations;
  final List<ForecastItem> hourly;
  final List<WeatherCardData> cards;
  const WeatherDashboard({
    required this.persona,
    required this.location,
    this.temperature,
    this.feelsLike,
    this.humidity,
    required this.description,
    required this.recommendations,
    required this.hourly,
    required this.cards,
    required this.dataStatus,
  });
  factory WeatherDashboard.fromJson(Map<String, dynamic> json) {
    final current = (json['current'] as Map?)?.cast<String, dynamic>() ?? {};
    final forecast = (json['forecast'] as Map?)?.cast<String, dynamic>() ?? {};
    return WeatherDashboard(
      persona: json['persona']?.toString() ?? 'commuter',
      location:
          (json['location'] as Map?)?['name']?.toString() ?? 'Your location',
      temperature: (current['temperature_c'] as num?)?.toDouble(),
      feelsLike: (current['feels_like_c'] as num?)?.toDouble(),
      humidity: (current['humidity_pct'] as num?)?.round(),
      description:
          current['weather_description']?.toString() ??
          'Conditions unavailable',
      recommendations: (json['recommendations'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      hourly: (forecast['hourly'] as List? ?? [])
          .take(12)
          .map((e) => ForecastItem.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      cards: (json['cards'] as List? ?? [])
          .map(
            (e) => WeatherCardData.fromJson((e as Map).cast<String, dynamic>()),
          )
          .toList(),
      dataStatus: json['data_status']?.toString() ?? 'fresh',
    );
  }
}

class ForecastItem {
  final double? temperature;
  final int? rainPercent;
  const ForecastItem(this.temperature, this.rainPercent);
  factory ForecastItem.fromJson(Map<String, dynamic> j) => ForecastItem(
    (j['temperature_c'] as num?)?.toDouble(),
    (((j['precipitation_probability'] as num?)?.toDouble() ?? 0) * 100).round(),
  );
}

class WeatherCardData {
  final String title, reason;
  const WeatherCardData(this.title, this.reason);
  factory WeatherCardData.fromJson(Map<String, dynamic> j) => WeatherCardData(
    j['title']?.toString() ?? 'Insight',
    j['reason']?.toString() ?? '',
  );
}
