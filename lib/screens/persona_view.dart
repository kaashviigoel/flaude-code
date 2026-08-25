import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mausam/models/weather.dart';
import 'package:mausam/services/weather_api.dart';
import 'package:mausam/widgets/glassmorphic_container.dart';

class PersonaViewScreen extends StatefulWidget {
  final String? selectedMode;

  const PersonaViewScreen({super.key, this.selectedMode});

  @override
  State<PersonaViewScreen> createState() => _PersonaViewScreenState();
}

class _PersonaViewScreenState extends State<PersonaViewScreen> {
  final WeatherApiService _apiService = WeatherApiService();

  DashboardResponse? _dashboardData;
  String? _errorMessage;
  bool _loading = true;

  static const Color accentColor = Color(0xFFFFCD00);
  static const Color backgroundColor = Color(0xFF101820);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      debugPrint('========== PERSONA WEATHER ==========');
      debugPrint('Starting location...');

      final position = await _apiService.currentPosition();

      debugPrint(
        'Location received: '
        '${position.latitude}, ${position.longitude}',
      );

      final data = await _apiService.fetchDashboard(
        lat: position.latitude,
        lon: position.longitude,
        persona: widget.selectedMode ?? 'health',
      );

      debugPrint('Persona weather received.');

      if (!mounted) return;

      setState(() {
        _dashboardData = data;
      });
    } catch (e, stackTrace) {
      debugPrint('================ WEATHER ERROR ================');
      debugPrint('ERROR: $e');
      debugPrint('STACK TRACE: $stackTrace');
      debugPrint('===============================================');

      if (!mounted) return;

      setState(() {
        _dashboardData = null;
      });
    }
  }

  String get _normalisedPersona {
    final mode = (widget.selectedMode ?? 'health').toLowerCase();

    switch (mode) {
      case 'health':
        return 'health';

      case 'fitness':
        return 'fitness';

      case 'beach':
      case 'beachgoer':
      case 'surf':
      case 'surfer':
        return 'beach';

      case 'travel':
      case 'traveller':
      case 'traveler':
        return 'travel';

      case 'family':
      case 'parents':
      case 'parent':
        return 'family';

      case 'agriculture':
      case 'gardener':
      case 'gardening':
        return 'agriculture';

      case 'commute':
      case 'commuter':
        return 'commute';

      case 'events':
      case 'event':
      case 'event_planner':
        return 'events';

      default:
        return 'health';
    }
  }

  String get _backendPersona {
    switch (_normalisedPersona) {
      case 'travel':
        return 'traveller';

      case 'commute':
        return 'commuter';

      case 'fitness':
        return 'fitness';

      case 'health':
        return 'health';

      default:
        return 'health';
    }
  }

  String get _personaName {
    switch (_normalisedPersona) {
      case 'health':
        return 'HEALTH';

      case 'fitness':
        return 'FITNESS';

      case 'beach':
        return 'BEACH & SURF';

      case 'travel':
        return 'TRAVEL';

      case 'family':
        return 'FAMILY';

      case 'agriculture':
        return 'AGRICULTURE';

      case 'commute':
        return 'COMMUTE';

      case 'events':
        return 'EVENTS';

      default:
        return 'HEALTH';
    }
  }

  String get _headline {
    switch (_normalisedPersona) {
      case 'health':
        return 'Breathe\nEasy';

      case 'fitness':
        return 'Peak\nPerformance';

      case 'beach':
        return 'Good\nTides';

      case 'travel':
        return 'Smooth\nJourney';

      case 'family':
        return 'Plan\nTheir Day';

      case 'agriculture':
        return 'Grow With\nThe Weather';

      case 'commute':
        return 'Clear\nTransit';

      case 'events':
        return 'A Good\nDay For It';

      default:
        return 'Breathe\nEasy';
    }
  }

  String get _subtitle {
    switch (_normalisedPersona) {
      case 'health':
        return 'Weather insights focused on your wellbeing.';

      case 'fitness':
        return 'Find the best conditions for your workout.';

      case 'beach':
        return 'Know the conditions before heading out.';

      case 'travel':
        return 'Weather intelligence for a smoother journey.';

      case 'family':
        return 'Plan school, commutes and outdoor time.';

      case 'agriculture':
        return 'Weather conditions for better planning.';

      case 'commute':
        return 'Know what the road conditions look like.';

      case 'events':
        return 'Find the best weather window for your plans.';

      default:
        return 'Personalised weather for you.';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _dashboardData == null) {
      return _buildLoadingState();
    }

    if (_errorMessage != null && _dashboardData == null) {
      return _buildErrorState();
    }

    final current = _dashboardData?.current;
    final forecast = _dashboardData?.forecast;

    final temperature = current?.temperatureC;
    final condition = current?.weatherDescription ?? 'Weather unavailable';

    final humidity = current?.humidityPct;
    final uv = current?.uvIndex;

    final locationName = _dashboardData?.location.name ?? 'Current location';

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: accentColor,
          backgroundColor: const Color(0xFF172330),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'MAUSAM',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 7,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                _buildPersonaBadge(),

                const SizedBox(height: 18),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        locationName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.6),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('EEE, d MMM').format(DateTime.now()),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Text(
                  _headline,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 44,
                    fontWeight: FontWeight.w400,
                    height: 1.03,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  _subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),

                const SizedBox(height: 24),
                _buildCurrentWeatherCard(
                  temperature: temperature,
                  condition: condition,
                  humidity: humidity,
                  uv: uv,
                ),

                const SizedBox(height: 30),
                Text(
                  _sectionTitle,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 23,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 14),

                _buildPersonaContent(
                  temperature: temperature,
                  humidity: humidity,
                  uv: uv,
                  condition: condition,
                  hourly: forecast?.hourly,
                ),

                const SizedBox(height: 30),
                _buildSectionHeader(title: 'Hourly Outlook', action: 'Swipe →'),

                const SizedBox(height: 14),

                _buildHourlyOutlook(forecast?.hourly),

                const SizedBox(height: 30),
                _buildSectionHeader(title: '7-Day Outlook', action: 'Forecast'),

                const SizedBox(height: 14),

                _buildDailyOutlook(forecast?.daily),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: accentColor,
              ),
            ),
            SizedBox(height: 18),
            Text(
              'Reading the sky...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                color: Colors.white54,
                size: 42,
              ),
              const SizedBox(height: 18),
              const Text(
                'Weather data unavailable',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Something went wrong.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: _loadData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.black,
                ),
                child: const Text('TRY AGAIN'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonaBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_personaIcon, size: 14, color: accentColor),
          const SizedBox(width: 7),
          Text(
            '$_personaName PROFILE',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  IconData get _personaIcon {
    switch (_normalisedPersona) {
      case 'health':
        return Icons.favorite_outline;

      case 'fitness':
        return Icons.directions_run;

      case 'beach':
        return Icons.waves_outlined;

      case 'travel':
        return Icons.flight_takeoff_outlined;

      case 'family':
        return Icons.family_restroom;

      case 'agriculture':
        return Icons.eco_outlined;

      case 'commute':
        return Icons.directions_car_outlined;

      case 'events':
        return Icons.celebration_outlined;

      default:
        return Icons.cloud_outlined;
    }
  }

  Widget _buildCurrentWeatherCard({
    required double? temperature,
    required String condition,
    required double? humidity,
    required double? uv,
  }) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      backgroundColor: Colors.white.withValues(alpha: 0.045),
      borderColor: Colors.white.withValues(alpha: 0.09),
      child: Row(
        children: [
          _getWeatherIcon(condition, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  temperature == null ? '--°' : '${temperature.round()}°',
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  condition,
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _smallWeatherValue(
                'Humidity',
                humidity == null ? '—' : '${humidity.round()}%',
              ),
              const SizedBox(height: 8),
              _smallWeatherValue(
                'UV',
                uv == null ? '—' : uv.toStringAsFixed(0),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallWeatherValue(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label ',
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.4),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  String get _sectionTitle {
    switch (_normalisedPersona) {
      case 'health':
        return 'Your Health Today';

      case 'fitness':
        return 'Workout Conditions';

      case 'beach':
        return 'Beach Conditions';

      case 'travel':
        return 'Journey Check';

      case 'family':
        return 'Plan Their Day';

      case 'agriculture':
        return 'Field Conditions';

      case 'commute':
        return 'Transit Conditions';

      case 'events':
        return 'Event Conditions';

      default:
        return 'Today';
    }
  }

  Widget _buildPersonaContent({
    required double? temperature,
    required double? humidity,
    required double? uv,
    required String condition,
    required List<ForecastPeriod>? hourly,
  }) {
    switch (_normalisedPersona) {
      case 'health':
        return _buildHealthContent(temperature, humidity, uv);

      case 'fitness':
        return _buildFitnessContent(temperature, humidity, uv, hourly);

      case 'beach':
        return _buildBeachContent(temperature, uv, condition);

      case 'travel':
        return _buildTravelContent(temperature, condition, hourly);

      case 'family':
        return _buildFamilyContent(temperature, condition, hourly);

      case 'agriculture':
        return _buildAgricultureContent(
          temperature,
          humidity,
          condition,
          hourly,
        );

      case 'commute':
        return _buildCommuteContent(condition, hourly);

      case 'events':
        return _buildEventsContent(temperature, humidity, condition, hourly);

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHealthContent(
    double? temperature,
    double? humidity,
    double? uv,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _metricCard(
                title: 'AIR QUALITY',
                value: '—',
                subtitle: 'Not available',
                icon: Icons.air,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _metricCard(
                title: 'POLLEN',
                value: '—',
                subtitle: 'Not available',
                icon: Icons.grass_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _metricCard(
                title: 'UV INDEX',
                value: uv == null ? '—' : uv.toStringAsFixed(0),
                subtitle: _uvDescription(uv),
                icon: Icons.wb_sunny_outlined,
                highlighted: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _metricCard(
                title: 'HUMIDITY',
                value: humidity == null ? '—' : '${humidity.round()}%',
                subtitle: 'Current',
                icon: Icons.water_drop_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _insightCard(
          icon: Icons.lightbulb_outline,
          title: 'Health insight',
          text: _healthInsight(temperature, humidity, uv),
        ),
      ],
    );
  }

  Widget _buildFitnessContent(
    double? temperature,
    double? humidity,
    double? uv,
    List<ForecastPeriod>? hourly,
  ) {
    final bestHour = _findBestOutdoorHour(hourly);

    return Column(
      children: [
        _highlightCard(
          icon: Icons.directions_run,
          label: 'BEST TIME TO WORK OUT',
          value: bestHour,
          description: 'Based on the available hourly weather forecast.',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _metricCard(
                title: 'TEMPERATURE',
                value: temperature == null ? '—' : '${temperature.round()}°',
                subtitle: 'Current',
                icon: Icons.thermostat_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _metricCard(
                title: 'UV INDEX',
                value: uv == null ? '—' : uv.toStringAsFixed(0),
                subtitle: _uvDescription(uv),
                icon: Icons.wb_sunny_outlined,
                highlighted: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _metricCard(
                title: 'HUMIDITY',
                value: humidity == null ? '—' : '${humidity.round()}%',
                subtitle: 'Current',
                icon: Icons.water_drop_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _metricCard(
                title: 'WIND',
                value: '—',
                subtitle: 'Not available',
                icon: Icons.air_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBeachContent(double? temperature, double? uv, String condition) {
    return Column(
      children: [
        _highlightCard(
          icon: Icons.waves_outlined,
          label: 'SEA CONDITIONS',
          value: 'Data unavailable',
          description:
              'Tide, wave and water-temperature data are not connected yet.',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _metricCard(
                title: 'WEATHER',
                value: _shortCondition(condition),
                subtitle: 'Current',
                icon: Icons.cloud_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _metricCard(
                title: 'UV INDEX',
                value: uv == null ? '—' : uv.toStringAsFixed(0),
                subtitle: _uvDescription(uv),
                icon: Icons.wb_sunny_outlined,
                highlighted: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _metricCard(
                title: 'WAVE HEIGHT',
                value: '—',
                subtitle: 'Not available',
                icon: Icons.waves_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _metricCard(
                title: 'TIDE',
                value: '—',
                subtitle: 'Not available',
                icon: Icons.water_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTravelContent(
    double? temperature,
    String condition,
    List<ForecastPeriod>? hourly,
  ) {
    final rainLikely = _rainLikely(hourly);

    return Column(
      children: [
        _highlightCard(
          icon: Icons.luggage_outlined,
          label: 'PACKING CHECK',
          value: rainLikely ? 'Pack a rain jacket' : 'Weather looks manageable',
          description: rainLikely
              ? 'Rain appears in the available forecast.'
              : 'No rain detected in the available hourly forecast.',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _metricCard(
                title: 'TEMPERATURE',
                value: temperature == null ? '—' : '${temperature.round()}°',
                subtitle: 'Current',
                icon: Icons.thermostat_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _metricCard(
                title: 'CONDITION',
                value: _shortCondition(condition),
                subtitle: 'Current',
                icon: Icons.cloud_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _metricCard(
          title: 'SEVERE WEATHER',
          value: '—',
          subtitle: 'Alert data not connected',
          icon: Icons.warning_amber_outlined,
        ),
      ],
    );
  }

  Widget _buildFamilyContent(
    double? temperature,
    String condition,
    List<ForecastPeriod>? hourly,
  ) {
    final morningCondition = _firstUsefulForecast(hourly);

    return Column(
      children: [
        _highlightCard(
          icon: Icons.school_outlined,
          label: 'SCHOOL COMMUTE',
          value: morningCondition,
          description: 'Based on the earliest available forecast period.',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _metricCard(
                title: 'TEMPERATURE',
                value: temperature == null ? '—' : '${temperature.round()}°',
                subtitle: 'Current',
                icon: Icons.thermostat_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _metricCard(
                title: 'RAIN ALERT',
                value: _rainLikely(hourly) ? 'YES' : 'LOW',
                subtitle: 'Hourly forecast',
                icon: Icons.umbrella_outlined,
                highlighted: _rainLikely(hourly),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _metricCard(
          title: 'SEVERE WEATHER',
          value: '—',
          subtitle: 'Alert data not connected',
          icon: Icons.warning_amber_outlined,
        ),
      ],
    );
  }

  Widget _buildAgricultureContent(
    double? temperature,
    double? humidity,
    String condition,
    List<ForecastPeriod>? hourly,
  ) {
    return Column(
      children: [
        _highlightCard(
          icon: Icons.eco_outlined,
          label: 'FIELD CONDITIONS',
          value: _agricultureSummary(condition, temperature),
          description: 'Built from currently available weather data.',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _metricCard(
                title: 'HUMIDITY',
                value: humidity == null ? '—' : '${humidity.round()}%',
                subtitle: 'Current',
                icon: Icons.water_drop_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _metricCard(
                title: 'RAINFALL',
                value: _rainLikely(hourly) ? 'LIKELY' : '—',
                subtitle: _rainLikely(hourly) ? 'In forecast' : 'Not available',
                icon: Icons.grain_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _metricCard(
                title: 'SOIL MOISTURE',
                value: '—',
                subtitle: 'Not available',
                icon: Icons.water_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _metricCard(
                title: 'FROST RISK',
                value: '—',
                subtitle: 'Not available',
                icon: Icons.ac_unit_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommuteContent(String condition, List<ForecastPeriod>? hourly) {
    final rain = _rainLikely(hourly);

    return Column(
      children: [
        _highlightCard(
          icon: Icons.directions_car_outlined,
          label: 'DEPARTURE CONDITIONS',
          value: rain ? 'Rain may affect travel' : 'Weather looks clear',
          description: 'Based on the available weather forecast.',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _metricCard(
                title: 'VISIBILITY',
                value: '—',
                subtitle: 'Not available',
                icon: Icons.visibility_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _metricCard(
                title: 'RAIN',
                value: rain ? 'LIKELY' : 'LOW',
                subtitle: 'Forecast',
                icon: Icons.water_drop_outlined,
                highlighted: rain,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _metricCard(
                title: 'FOG',
                value: '—',
                subtitle: 'Not available',
                icon: Icons.blur_on_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _metricCard(
                title: 'STORMS',
                value: '—',
                subtitle: 'Alert data unavailable',
                icon: Icons.thunderstorm_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEventsContent(
    double? temperature,
    double? humidity,
    String condition,
    List<ForecastPeriod>? hourly,
  ) {
    final bestHour = _findBestOutdoorHour(hourly);

    return Column(
      children: [
        _highlightCard(
          icon: Icons.celebration_outlined,
          label: 'BEST EVENT WINDOW',
          value: bestHour,
          description: 'Recommended from the available hourly conditions.',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _metricCard(
                title: 'TEMPERATURE',
                value: temperature == null ? '—' : '${temperature.round()}°',
                subtitle: 'Current',
                icon: Icons.thermostat_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _metricCard(
                title: 'RAIN',
                value: _rainLikely(hourly) ? 'LIKELY' : 'LOW',
                subtitle: 'Forecast',
                icon: Icons.water_drop_outlined,
                highlighted: _rainLikely(hourly),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _metricCard(
          title: 'COMFORT INDEX',
          value: _comfortIndex(temperature, humidity),
          subtitle: 'Based on available weather data',
          icon: Icons.spa_outlined,
          highlighted: true,
        ),
      ],
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    bool highlighted = false,
  }) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      backgroundColor: highlighted
          ? accentColor.withValues(alpha: 0.07)
          : Colors.white.withValues(alpha: 0.045),
      borderColor: highlighted
          ? accentColor.withValues(alpha: 0.22)
          : Colors.white.withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 19,
            color: highlighted ? accentColor : Colors.white54,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _highlightCard({
    required IconData icon,
    required String label,
    required String value,
    required String description,
  }) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      backgroundColor: accentColor.withValues(alpha: 0.065),
      borderColor: accentColor.withValues(alpha: 0.20),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.3,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 10,
                    height: 1.35,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _insightCard({
    required IconData icon,
    required String title,
    required String text,
  }) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      backgroundColor: Colors.white.withValues(alpha: 0.035),
      borderColor: Colors.white.withValues(alpha: 0.07),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: accentColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyOutlook(List<ForecastPeriod>? hourly) {
    final list = hourly != null && hourly.isNotEmpty
        ? hourly.take(8).toList()
        : <ForecastPeriod>[];

    if (list.isEmpty) {
      return GlassmorphicContainer(
        padding: const EdgeInsets.all(18),
        borderRadius: 20,
        backgroundColor: Colors.white.withValues(alpha: 0.04),
        borderColor: Colors.white.withValues(alpha: 0.08),
        child: Row(
          children: [
            const Icon(
              Icons.schedule_outlined,
              color: Colors.white38,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Hourly forecast is not available from the backend yet.',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 124,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = list[index];

          final time = index == 0
              ? 'NOW'
              : item.startsAt != null
              ? DateFormat('h a').format(item.startsAt!)
              : '--';

          final temperature = item.temperatureC;

          final condition = item.weatherDescription ?? 'Weather';

          return GlassmorphicContainer(
            width: 82,
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
            borderRadius: 20,
            backgroundColor: Colors.white.withValues(alpha: 0.045),
            borderColor: Colors.white.withValues(alpha: 0.08),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
                _getWeatherIcon(condition, size: 23),
                Text(
                  temperature == null ? '--°' : '${temperature.round()}°',
                  style: const TextStyle(
                    fontSize: 15,
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
    final list = daily != null && daily.isNotEmpty
        ? daily.take(7).toList()
        : <ForecastPeriod>[];

    if (list.isEmpty) {
      return GlassmorphicContainer(
        padding: const EdgeInsets.all(18),
        borderRadius: 22,
        backgroundColor: Colors.white.withValues(alpha: 0.04),
        borderColor: Colors.white.withValues(alpha: 0.08),
        child: const Text(
          'Daily forecast unavailable.',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
      );
    }

    return GlassmorphicContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: 22,
      backgroundColor: Colors.white.withValues(alpha: 0.045),
      borderColor: Colors.white.withValues(alpha: 0.08),
      child: Column(
        children: List.generate(list.length, (index) {
          final item = list[index];

          final date = item.startsAt;

          final day = index == 0
              ? 'Today'
              : date != null
              ? DateFormat('EEE').format(date)
              : '--';

          final temp = item.temperatureC;

          final condition = item.weatherDescription ?? 'Weather';

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Row(
              children: [
                SizedBox(
                  width: 52,
                  child: Text(
                    day,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                _getWeatherIcon(condition, size: 19),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    condition,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                ),
                Text(
                  temp == null ? '--°' : '${temp.round()}°',
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

  Widget _buildSectionHeader({required String title, required String action}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
        Text(
          action,
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 0.5,
            color: Colors.white.withValues(alpha: 0.35),
          ),
        ),
      ],
    );
  }

  String _uvDescription(double? uv) {
    if (uv == null) return 'Not available';

    if (uv < 3) return 'Low';
    if (uv < 6) return 'Moderate';
    if (uv < 8) return 'High';
    if (uv < 11) return 'Very high';

    return 'Extreme';
  }

  String _healthInsight(double? temperature, double? humidity, double? uv) {
    if (uv != null && uv >= 8) {
      return 'UV exposure is high right now. Consider limiting direct sun exposure.';
    }

    if (humidity != null && humidity >= 75) {
      return 'Humidity is high. Hydrate well and take breaks during outdoor activity.';
    }

    if (temperature != null && temperature >= 32) {
      return 'It is warm outside. Consider choosing a cooler time for prolonged outdoor activity.';
    }

    return 'Current weather conditions look relatively comfortable based on the available data.';
  }

  String _findBestOutdoorHour(List<ForecastPeriod>? hourly) {
    if (hourly == null || hourly.isEmpty) {
      return 'Not enough data';
    }

    ForecastPeriod? best;
    double? bestTemperature;

    for (final item in hourly.take(8)) {
      final temp = item.temperatureC;

      if (temp == null) continue;

      if (bestTemperature == null ||
          (temp - 22).abs() < (bestTemperature - 22).abs()) {
        bestTemperature = temp;
        best = item;
      }
    }

    if (best?.startsAt == null) {
      return 'See hourly forecast';
    }

    return DateFormat('h:mm a').format(best!.startsAt!);
  }

  bool _rainLikely(List<ForecastPeriod>? hourly) {
    if (hourly == null || hourly.isEmpty) {
      return false;
    }

    return hourly.take(8).any((item) {
      final description = (item.weatherDescription ?? '').toLowerCase();

      return description.contains('rain') ||
          description.contains('shower') ||
          description.contains('storm') ||
          description.contains('drizzle');
    });
  }

  String _firstUsefulForecast(List<ForecastPeriod>? hourly) {
    if (hourly == null || hourly.isEmpty) {
      return 'Forecast unavailable';
    }

    final first = hourly.first;

    final time = first.startsAt != null
        ? DateFormat('h:mm a').format(first.startsAt!)
        : 'Next forecast';

    final condition = first.weatherDescription ?? 'Weather available';

    return '$time · $condition';
  }

  String _agricultureSummary(String condition, double? temperature) {
    final lower = condition.toLowerCase();

    if (lower.contains('rain')) {
      return 'Rain in the forecast';
    }

    if (temperature != null && temperature >= 35) {
      return 'Hot conditions';
    }

    return 'Monitor current conditions';
  }

  String _comfortIndex(double? temperature, double? humidity) {
    if (temperature == null || humidity == null) {
      return '—';
    }

    double score = 100;

    score -= (temperature - 24).abs() * 4;
    score -= (humidity - 50).abs() * 0.5;

    score = score.clamp(0, 100);

    if (score >= 80) return 'Excellent';
    if (score >= 65) return 'Good';
    if (score >= 45) return 'Moderate';

    return 'Low';
  }

  String _shortCondition(String condition) {
    if (condition.length <= 18) {
      return condition;
    }

    return '${condition.substring(0, 17)}…';
  }

  Widget _getWeatherIcon(String condition, {double size = 24}) {
    final lower = condition.toLowerCase();

    if (lower.contains('storm') || lower.contains('thunder')) {
      return Icon(
        Icons.thunderstorm_outlined,
        color: Colors.white70,
        size: size,
      );
    }

    if (lower.contains('rain') ||
        lower.contains('shower') ||
        lower.contains('drizzle')) {
      return Icon(
        Icons.water_drop_outlined,
        color: const Color(0xFF4AC7F0),
        size: size,
      );
    }

    if (lower.contains('partly') ||
        (lower.contains('cloud') && lower.contains('sun'))) {
      return Icon(Icons.wb_cloudy_outlined, color: accentColor, size: size);
    }

    if (lower.contains('cloud')) {
      return Icon(Icons.cloud_outlined, color: Colors.white70, size: size);
    }

    if (lower.contains('snow')) {
      return Icon(Icons.ac_unit_outlined, color: Colors.white70, size: size);
    }

    return Icon(Icons.wb_sunny_outlined, color: accentColor, size: size);
  }
}
