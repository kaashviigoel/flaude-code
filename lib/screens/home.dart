import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mausam/models/weather.dart';
import 'package:mausam/services/weather_api.dart';
import 'package:mausam/widgets/glassmorphic_container.dart';
import 'package:geocoding/geocoding.dart';

class HomeScreen extends StatefulWidget {
  final String? selectedMode;

  const HomeScreen({super.key, this.selectedMode});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherApiService _apiService = WeatherApiService();
  final Geocoding _geocoding = Geocoding();

  DashboardResponse? _dashboardData;

  String _locationName = 'Current location';

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      debugPrint('========== HOME WEATHER ==========');
      debugPrint('1. Starting location...');

      final position = await _apiService.currentPosition();

      debugPrint(
        '2. Location received: '
        '${position.latitude}, ${position.longitude}',
      );

      debugPrint('3. Requesting weather from backend...');

      final data = await _apiService
          .fetchDashboard(
            lat: position.latitude,
            lon: position.longitude,
            persona: widget.selectedMode ?? 'commuter',
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Weather request timed out after 15 seconds');
            },
          );

      debugPrint('4. Weather received successfully.');

      if (!mounted) return;

      setState(() {
        _dashboardData = data;
        _isLoading = false;
        _errorMessage = null;
      });

      // ------------------------------------------------------------
      // 3. REVERSE GEOCODE SEPARATELY
      //
      // If this fails, weather still stays on screen.
      // ------------------------------------------------------------

      debugPrint('5. Looking up location name...');

      try {
        final placemarks = await _geocoding
            .placemarkFromCoordinates(position.latitude, position.longitude)
            .timeout(const Duration(seconds: 5));

        if (!mounted) return;

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;

          final city =
              place.locality ??
              place.subAdministrativeArea ??
              place.administrativeArea ??
              'Current location';

          setState(() {
            _locationName = city;
          });

          debugPrint('6. Location name: $_locationName');
        }
      } catch (e) {
        debugPrint('Reverse geocoding failed/timed out: $e');

        // This is NOT a fatal weather error.
        // Weather has already loaded.
        if (mounted) {
          setState(() {
            _locationName = 'Current location';
          });
        }
      }

      debugPrint('========== HOME WEATHER COMPLETE ==========');
    } catch (e, stackTrace) {
      debugPrint('========== HOME WEATHER ERROR ==========');
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
    final current = _dashboardData?.current;
    final forecast = _dashboardData?.forecast;

    final currentTemperature = current?.temperatureC?.round();

    final condition = current?.weatherDescription;

    final displayCondition = condition == null || condition.trim().isEmpty
        ? 'Weather unavailable'
        : _capitalizeCondition(condition);

    final daily = forecast?.daily ?? const <ForecastPeriod>[];

    final todayForecast = daily.isNotEmpty ? daily.first : null;

    final todayHigh = todayForecast?.temperatureMaxC?.round();

    final todayLow = todayForecast?.temperatureMinC?.round();

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

            padding: const EdgeInsets.fromLTRB(20, 16, 20, 150),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [
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

                if (_isLoading && _dashboardData == null)
                  _buildLoadingState()
                else if (_errorMessage != null && _dashboardData == null)
                  _buildErrorState()
                else ...[
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 17,
                        color: Colors.white.withValues(alpha: 0.55),
                      ),

                      const SizedBox(width: 6),

                      Expanded(
                        child: Text(
                          _locationName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.72),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),

                      Text(
                        _formatCurrentDateShort(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            _getWeatherIcon(condition ?? '', size: 52),

                            const SizedBox(width: 14),

                            Text(
                              currentTemperature == null
                                  ? '--°'
                                  : '$currentTemperature°',

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

                        Text(
                          displayCondition,

                          textAlign: TextAlign.center,

                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 8),
                        if (todayHigh != null || todayLow != null)
                          Text(
                            _buildHighLowText(todayHigh, todayLow),

                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.55),
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        else
                          Text(
                            'High / low unavailable',

                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),
                  _buildSectionTitle('HOURLY FORECAST'),

                  const SizedBox(height: 12),

                  _buildHourlyStrip(forecast?.hourly),

                  const SizedBox(height: 28),
                  _buildSectionTitle('7-DAY OUTLOOK'),

                  const SizedBox(height: 12),

                  _buildDailyOutlook(forecast?.daily),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.6,
        color: Colors.white.withValues(alpha: 0.55),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 600,

      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            const SizedBox(
              width: 28,
              height: 28,

              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFFFCD00),
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Loading weather...',

              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return SizedBox(
      height: 600,

      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 52,
              color: Colors.white.withValues(alpha: 0.55),
            ),

            const SizedBox(height: 20),

            const Text(
              'Weather data unavailable',
              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: Text(
                'We could not load the latest weather data.',

                textAlign: TextAlign.center,

                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _loadWeatherData,

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFCD00),

                foregroundColor: Colors.black,

                elevation: 0,

                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 13,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),

              child: const Text(
                'TRY AGAIN',

                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyStrip(List<ForecastPeriod>? hourly) {
    final list = hourly != null && hourly.isNotEmpty
        ? hourly.take(8).toList()
        : <ForecastPeriod>[];

    if (list.isEmpty) {
      return GlassmorphicContainer(
        height: 110,

        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),

        borderRadius: 20,

        backgroundColor: Colors.white.withValues(alpha: 0.04),

        borderColor: Colors.white.withValues(alpha: 0.08),

        child: Center(
          child: Text(
            'Hourly forecast unavailable',

            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 110,

      child: ListView.separated(
        scrollDirection: Axis.horizontal,

        physics: const BouncingScrollPhysics(),

        itemCount: list.length,

        separatorBuilder: (context, index) {
          return const SizedBox(width: 12);
        },

        itemBuilder: (context, index) {
          final item = list[index];

          final timeStr = index == 0
              ? 'Now'
              : item.startsAt != null
              ? DateFormat('h a').format(item.startsAt!.toLocal())
              : '--';

          final temperature = item.temperatureC?.round();

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
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),

                _getWeatherIcon(item.weatherDescription ?? '', size: 22),

                Text(
                  temperature == null ? '--°' : '$temperature°',

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
    final list = daily != null && daily.isNotEmpty
        ? daily.take(7).toList()
        : <ForecastPeriod>[];

    if (list.isEmpty) {
      return GlassmorphicContainer(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
        borderRadius: 24,
        backgroundColor: Colors.white.withValues(alpha: 0.05),
        borderColor: Colors.white.withValues(alpha: 0.09),
        child: Center(
          child: Text(
            '7-day forecast unavailable',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),
        ),
      );
    }

    final allTemps = <double>[];

    for (final item in list) {
      if (item.temperatureMinC != null) {
        allTemps.add(item.temperatureMinC!);
      }

      if (item.temperatureMaxC != null) {
        allTemps.add(item.temperatureMaxC!);
      }
    }

    final overallMin = allTemps.isEmpty
        ? 0.0
        : allTemps.reduce((a, b) => a < b ? a : b);

    final overallMax = allTemps.isEmpty
        ? 1.0
        : allTemps.reduce((a, b) => a > b ? a : b);

    final overallRange = (overallMax - overallMin).abs() < 1
        ? 1.0
        : overallMax - overallMin;

    return GlassmorphicContainer(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      borderRadius: 24,
      backgroundColor: Colors.white.withValues(alpha: 0.05),
      borderColor: Colors.white.withValues(alpha: 0.09),
      child: Column(
        children: List.generate(list.length, (index) {
          final item = list[index];

          final date = item.startsAt?.toLocal();

          final dayName = index == 0
              ? 'Today'
              : date != null
              ? DateFormat('EEE').format(date)
              : '--';

          final min = item.temperatureMinC?.round();
          final max = item.temperatureMaxC?.round();

          final precipitation = item.precipitationProbability;

          final popText = precipitation == null
              ? '--'
              : '${(precipitation * 100).round()}%';
          final minTemp = item.temperatureMinC ?? overallMin;
          final maxTemp = item.temperatureMaxC ?? minTemp;

          final temperatureRange = (maxTemp - minTemp).clamp(0.0, overallRange);

          double fillFraction = temperatureRange / overallRange;

          fillFraction = fillFraction.clamp(0.12, 1.0);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 58,
                  child: Text(
                    dayName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),

                SizedBox(
                  width: 72,
                  child: Row(
                    children: [
                      _getWeatherIcon(item.weatherDescription ?? '', size: 19),
                      const SizedBox(width: 5),
                      Text(
                        popText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.cyan.shade200,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  width: 34,
                  child: Text(
                    min == null ? '--°' : '$min°',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: SizedBox(
                    height: 5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 5,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                          FractionallySizedBox(
                            widthFactor: fillFraction,
                            child: Container(
                              height: 5,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xFF67B7D1),
                                    Color(0xFFFFCD00),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                SizedBox(
                  width: 34,
                  child: Text(
                    max == null ? '--°' : '$max°',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
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

    if (lower.contains('thunder')) {
      return Icon(
        Icons.thunderstorm_outlined,
        color: const Color(0xFFFFCD00),
        size: size,
      );
    }

    if (lower.contains('snow')) {
      return Icon(Icons.ac_unit, color: Colors.white70, size: size);
    }

    if (lower.contains('rain') || lower.contains('drizzle')) {
      return Icon(Icons.water_drop, color: const Color(0xFF4AC7F0), size: size);
    }

    if (lower.contains('cloud') && lower.contains('sun')) {
      return Icon(
        Icons.wb_cloudy_outlined,
        color: const Color(0xFFFFCD00),
        size: size,
      );
    }

    if (lower.contains('partly')) {
      return Icon(
        Icons.wb_cloudy_outlined,
        color: const Color(0xFFFFCD00),
        size: size,
      );
    }

    if (lower.contains('cloud')) {
      return Icon(Icons.cloud_outlined, color: Colors.white70, size: size);
    }

    if (lower.contains('clear') || lower.contains('sun')) {
      return Icon(
        Icons.wb_sunny_outlined,
        color: const Color(0xFFFFCD00),
        size: size,
      );
    }

    return Icon(Icons.cloud_outlined, color: Colors.white70, size: size);
  }

  String _formatCurrentDate() {
    return DateFormat('EEEE, d MMM').format(DateTime.now());
  }

  String _formatCurrentDateShort() {
    return DateFormat('EEE, d MMM').format(DateTime.now());
  }

  String _capitalizeCondition(String value) {
    if (value.isEmpty) return value;

    return value
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}'
                    '${word.substring(1)}',
        )
        .join(' ');
  }

  String _buildHighLowText(int? high, int? low) {
    if (high != null && low != null) {
      return 'H: $high°   L: $low°';
    }

    if (high != null) {
      return 'H: $high°';
    }

    if (low != null) {
      return 'L: $low°';
    }

    return 'High / low unavailable';
  }
}
