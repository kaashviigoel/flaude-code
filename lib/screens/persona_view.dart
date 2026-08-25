import 'package:flutter/material.dart';
import 'package:mausam/models/weather.dart';
import 'package:mausam/services/weather_api.dart';
import 'package:mausam/widgets/glassmorphic_container.dart';
import 'package:mausam/widgets/weather_card.dart';

class PersonaViewScreen extends StatefulWidget {
  final String? selectedMode;

  const PersonaViewScreen({super.key, this.selectedMode});

  @override
  State<PersonaViewScreen> createState() => _PersonaViewScreenState();
}

class _PersonaViewScreenState extends State<PersonaViewScreen> {
  final WeatherApiService _apiService = WeatherApiService();
  DashboardResponse? _dashboardData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final position = await _apiService.currentPosition();
    final data = await _apiService.fetchDashboard(
      lat: position.latitude,
      lon: position.longitude,
      persona: widget.selectedMode ?? 'health',
    );
    if (mounted) {
      setState(() {
        _dashboardData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final persona = (widget.selectedMode ?? 'HEALTH').toUpperCase();
    final personaTitle = _getHeadlineForPersona(persona);
    final badgeLabel = '$persona PROFILE';

    final current = _dashboardData?.current;
    final uv = current?.uvIndex ?? 6.0;
    final humidity = current?.humidityPct;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: const Color(0xFFFFCD00),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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

                const SizedBox(height: 24),

                // Persona Pill Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        color: Colors.white70,
                        size: 13,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        badgeLabel,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Big Serif Headline (e.g. "Breathe\nEasy")
                Text(
                  personaTitle,
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'serif',
                    color: Colors.white,
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 24),

                // AQI is not part of the backend contract yet, so do not show fabricated values.
                Text(
                  'Air quality data is not available from the weather provider.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
                ),

                // Trigger Levels Section
                const Text(
                  'Trigger Levels',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'serif',
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 14),

                // Trigger Levels Grid (Pollen, UV, Humidity)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Pollen Card
                    const Expanded(child: PollenCardWidget()),
                    const SizedBox(width: 14),
                    // Right Column: UV & Humidity
                    Expanded(
                      child: Column(
                        children: [
                          UvCardWidget(uvIndex: uv),
                          const SizedBox(height: 14),
                          HumidityCardWidget(humidity: humidity ?? 0),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Hourly Outlook Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Hourly Outlook',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'serif',
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Horizontal Outlook Cards with condition colored dots
                _buildHourlyOutlookStrip(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHourlyOutlookStrip() {
    final hours = [
      {
        'time': 'Now',
        'temp': '68°',
        'dotColor': const Color(0xFFF68B8B),
        'icon': Icons.wb_sunny_outlined,
      },
      {
        'time': '1 PM',
        'temp': '70°',
        'dotColor': const Color(0xFFF68B8B),
        'icon': Icons.wb_sunny,
      },
      {
        'time': '2 PM',
        'temp': '72°',
        'dotColor': const Color(0xFFFFCD00),
        'icon': Icons.wb_sunny,
      },
      {
        'time': '3 PM',
        'temp': '71°',
        'dotColor': const Color(0xFFFFCD00),
        'icon': Icons.cloud_outlined,
      },
    ];

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: hours.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = hours[index];

          return GlassmorphicContainer(
            width: 76,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            borderRadius: 20,
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            borderColor: Colors.white.withValues(alpha: 0.08),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['time'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                Icon(
                  item['icon'] as IconData,
                  color: const Color(0xFFFFCD00),
                  size: 22,
                ),
                Text(
                  item['temp'] as String,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: item['dotColor'] as Color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getHeadlineForPersona(String persona) {
    switch (persona.toUpperCase()) {
      case 'FITNESS':
        return 'Peak\nPerformance';
      case 'TRAVEL':
      case 'TRAVELLER':
        return 'Smooth\nJourney';
      case 'COMMUTE':
      case 'COMMUTER':
        return 'Clear\nTransit';
      case 'BEACH':
        return 'Sunny\nTides';
      case 'HEALTH':
      default:
        return 'Breathe\nEasy';
    }
  }
}
