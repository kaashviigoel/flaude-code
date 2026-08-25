import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mausam/models/weather.dart';
import 'package:mausam/services/weather_api.dart';
import 'package:mausam/widgets/glassmorphic_container.dart';

class HomeScreen extends StatefulWidget {
  final String? selectedMode;

  const HomeScreen({super.key, this.selectedMode});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherApiService _apiService = WeatherApiService();
  DashboardResponse? _dashboardData;

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    final position = await _apiService.currentPosition();
    final data = await _apiService.fetchDashboard(
      lat: position.latitude,
      lon: position.longitude,
      persona: widget.selectedMode ?? 'commuter',
    );
    if (mounted) {
      setState(() {
        _dashboardData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _dashboardData?.current;
    final forecast = _dashboardData?.forecast;

    final temp = current?.temperatureC?.round();
    final condition = current?.weatherDescription ?? 'Weather unavailable';
    final locationName = _dashboardData?.location.name ?? 'Current location';
    final dateStr = DateFormat('EEEE, d MMM').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadWeatherData,
          color: const Color(0xFFFFCD00),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Brand Title
                const Center(
                  child: Text(
                    'MAUSAM',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 8.0,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Main Hero Weather Card
                GlassmorphicContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 28,
                  ),
                  borderRadius: 28,
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  borderColor: Colors.white.withValues(alpha: 0.09),
                  child: Column(
                    children: [
                      Text(
                        locationName,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Temperature and Icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _getWeatherIcon(condition, size: 48),
                          const SizedBox(width: 14),
                          Text(
                            '$temp°',
                            style: const TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Condition description
                      Text(
                        condition,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'H: 32°   L: 18°',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.55),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Hourly Forecast Header
                Text(
                  'HOURLY FORECAST',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),

                const SizedBox(height: 12),

                // Hourly Forecast Cards Row
                _buildHourlyStrip(forecast?.hourly),

                const SizedBox(height: 28),

                // 7-Day Outlook Header
                Text(
                  '7-DAY OUTLOOK',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),

                const SizedBox(height: 12),

                // 7-Day Outlook Card
                _buildDailyOutlook(forecast?.daily),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHourlyStrip(List<ForecastPeriod>? hourly) {
    final list = hourly != null && hourly.isNotEmpty
        ? hourly.take(6).toList()
        : const <ForecastPeriod>[];

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: list.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = list[index];
          final timeStr = index == 0
              ? 'Now'
              : (item.startsAt != null
                    ? DateFormat('HH:mm').format(item.startsAt!)
                    : '${14 + index}:00');
          final t = item.temperatureC?.round();

          return GlassmorphicContainer(
            width: 78,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            borderRadius: 18,
            backgroundColor: Colors.white.withValues(alpha: 0.04),
            borderColor: Colors.white.withValues(alpha: 0.08),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                _getWeatherIcon(item.weatherDescription ?? 'Sunny', size: 22),
                Text(
                  t == null ? '--' : '$t°',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDailyOutlook(List<ForecastPeriod>? daily) {
    final defaultDays = [
      {'day': 'Today', 'icon': 'cloud_sun', 'pop': '10%', 'min': 18, 'max': 32},
      {'day': 'Thu', 'icon': 'rain', 'pop': '80%', 'min': 16, 'max': 24},
      {'day': 'Fri', 'icon': 'cloud', 'pop': '20%', 'min': 15, 'max': 22},
      {'day': 'Sat', 'icon': 'sun', 'pop': '0%', 'min': 17, 'max': 29},
      {'day': 'Sun', 'icon': 'sun', 'pop': '0%', 'min': 19, 'max': 31},
    ];

    return GlassmorphicContainer(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      borderRadius: 24,
      backgroundColor: Colors.white.withValues(alpha: 0.05),
      borderColor: Colors.white.withValues(alpha: 0.09),
      child: Column(
        children: List.generate(defaultDays.length, (index) {
          final item = defaultDays[index];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                // Day name
                SizedBox(
                  width: 50,
                  child: Text(
                    item['day'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Icon + Precip %
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _getWeatherIcon(item['icon'] as String, size: 18),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 38,
                      child: Text(
                        item['pop'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.cyan.shade200,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 8),

                // Min temp
                Text(
                  '${item['min']}°',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),

                const SizedBox(width: 10),

                // Temperature range bar
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor:
                            (((item['max'] as int) - (item['min'] as int)) /
                                    20.0)
                                .clamp(0.2, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF67B7D1), Color(0xFFFFCD00)],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Max temp
                Text(
                  '${item['max']}°',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _getWeatherIcon(String condition, {double size = 24}) {
    final lower = condition.toLowerCase();
    if (lower.contains('rain') || lower == 'rain') {
      return Icon(Icons.water_drop, color: const Color(0xFF4AC7F0), size: size);
    }
    if (lower.contains('cloud') && lower.contains('sun') ||
        lower.contains('partly')) {
      return Icon(
        Icons.wb_cloudy_outlined,
        color: const Color(0xFFFFCD00),
        size: size,
      );
    }
    if (lower.contains('cloud')) {
      return Icon(Icons.cloud_outlined, color: Colors.white70, size: size);
    }
    return Icon(
      Icons.wb_sunny_outlined,
      color: const Color(0xFFFFCD00),
      size: size,
    );
  }
}
