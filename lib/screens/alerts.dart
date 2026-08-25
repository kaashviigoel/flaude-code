import 'package:flutter/material.dart';
import 'package:mausam/models/weather.dart';
import 'package:mausam/services/weather_api.dart';
import 'package:mausam/widgets/alert_card.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final WeatherApiService _apiService = WeatherApiService();
  WeatherAlerts? _alerts;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() => _isLoading = true);
    final position = await _apiService.currentPosition();
    final alerts = await _apiService.fetchAlerts(
      lat: position.latitude,
      lon: position.longitude,
    );
    if (mounted) {
      setState(() {
        _alerts = alerts;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final alertItems = _alerts?.items ?? [];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadAlerts,
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

                // Alerts Serif Title
                const Text(
                  'Alerts',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'serif',
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 14),

                // Active Warnings Pill Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'ACTIVE WEATHER WARNINGS IN YOUR AREA',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Section Label
                Text(
                  'ACTIVE ALERTS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),

                const SizedBox(height: 14),

                // Alert Cards List
                if (_isLoading && alertItems.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(
                        color: Color(0xFFFFCD00),
                      ),
                    ),
                  )
                else ...[
                  // Card 1: Critical Heavy Rain
                  AlertCardWidget(
                    alert: WeatherAlert(
                      event: 'Heavy Rain Alert',
                      severity: 'critical',
                      description:
                          'Expect severe localized flooding and significant travel disruption. Seek shelter immediately if outdoors.',
                    ),
                    locationName: 'Bengaluru',
                    timeLabel: '8 PM',
                  ),

                  // Card 2: Warning Heat Alert
                  AlertCardWidget(
                    alert: WeatherAlert(
                      event: 'Heat Alert',
                      severity: 'warning',
                      description:
                          'Extreme temperatures expected. Prolonged exposure may lead to heat exhaustion. Stay hydrated and indoors if possible.',
                    ),
                    locationName: 'Bengaluru',
                    timeLabel: 'TOMORROW, 12-3 PM',
                  ),

                  // Card 3: Advisory Strong Wind
                  AlertCardWidget(
                    alert: WeatherAlert(
                      event: 'Strong Wind',
                      severity: 'advisory',
                      description:
                          'Gusts up to 45 km/h. Secure loose outdoor objects and exercise caution while driving high-profile vehicles.',
                    ),
                    locationName: 'Bengaluru Outskirts',
                    timeLabel: 'ONGOING',
                  ),

                  // Any additional dynamic items from API
                  ...alertItems.skip(3).map((a) => AlertCardWidget(alert: a)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
