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
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      debugPrint('========== ALERTS ==========');
      debugPrint('Starting location...');

      final position = await _apiService.currentPosition();

      debugPrint(
        'Alert location: '
        '${position.latitude}, ${position.longitude}',
      );

      final alerts = await _apiService.fetchAlerts(
        lat: position.latitude,
        lon: position.longitude,
      );

      debugPrint('Alerts received: ${alerts.items.length}');

      if (!mounted) return;

      setState(() {
        _alerts = alerts;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e, stackTrace) {
      debugPrint('========== ALERTS ERROR ==========');
      debugPrint('ERROR: $e');
      debugPrint('STACK TRACE: $stackTrace');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
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

            padding: const EdgeInsets.fromLTRB(20, 16, 20, 150),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // --------------------------------------------------
                // MAUSAM
                // --------------------------------------------------
                const Center(
                  child: Text(
                    'MAUSAM',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 8,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // --------------------------------------------------
                // TITLE
                // --------------------------------------------------
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

                // --------------------------------------------------
                // WARNING BADGE
                // --------------------------------------------------
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                      width: 1,
                    ),
                  ),

                  child: Row(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 14,
                      ),

                      const SizedBox(width: 6),

                      Text(
                        'ACTIVE WEATHER WARNINGS IN YOUR AREA',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // --------------------------------------------------
                // SECTION TITLE
                // --------------------------------------------------
                Text(
                  'ACTIVE ALERTS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),

                const SizedBox(height: 18),

                // --------------------------------------------------
                // LOADING
                // --------------------------------------------------
                if (_isLoading)
                  _buildLoadingState()
                // --------------------------------------------------
                // ERROR
                // --------------------------------------------------
                else if (_errorMessage != null)
                  _buildErrorState()
                // --------------------------------------------------
                // NO ALERTS
                // --------------------------------------------------
                else if (alertItems.isEmpty)
                  _buildNoAlertsState()
                // --------------------------------------------------
                // ACTUAL ALERTS
                // --------------------------------------------------
                else
                  ...alertItems.map(
                    (alert) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: AlertCardWidget(alert: alert),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================================================================
  // LOADING
  // ================================================================

  Widget _buildLoadingState() {
    return SizedBox(
      width: double.infinity,
      height: 260,

      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            const SizedBox(
              width: 30,
              height: 30,

              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFFFFCD00),
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Checking your area...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // ERROR
  // ================================================================

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),

      child: Column(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 42,
            color: Colors.white.withValues(alpha: 0.45),
          ),

          const SizedBox(height: 16),

          const Text(
            'Alerts unavailable',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'We couldn’t check for active weather warnings right now.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),

          const SizedBox(height: 22),

          ElevatedButton(
            onPressed: _loadAlerts,

            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFCD00),
              foregroundColor: Colors.black,
              elevation: 0,

              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),

            child: const Text(
              'TRY AGAIN',
              style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // NO ACTIVE ALERTS
  // ================================================================

  Widget _buildNoAlertsState() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 42),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),

      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,

            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
            ),

            child: Icon(
              Icons.check_rounded,
              size: 28,
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'No active alerts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'There are no active weather warnings in your area.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}
