import 'package:flutter/material.dart';
import 'package:mausam/models/user_profile.dart';
import 'package:mausam/services/weather_api.dart';
import 'package:mausam/widgets/glassmorphic_container.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  final WeatherApiService _apiService = WeatherApiService();
  final TextEditingController _searchController = TextEditingController();
  List<SavedLocationModel> _savedLocations = [];

  @override
  void initState() {
    super.initState();
    _loadSavedLocations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedLocations() async {
    try {
      final locations = await _apiService.fetchSavedLocations('demo-user');

      if (!mounted) return;

      setState(() {
        _savedLocations = locations;
      });
    } catch (e, stackTrace) {
      debugPrint('========== SAVED LOCATIONS ERROR ==========');
      debugPrint('ERROR: $e');
      debugPrint('STACK TRACE: $stackTrace');

      if (!mounted) return;

      // Do NOT crash the Maps screen just because
      // saved locations are unavailable.
      setState(() {
        _savedLocations = [];
      });
    }
  }

  Future<void> _showAddLocationDialog() async {
    final nameCtrl = TextEditingController();
    final latCtrl = TextEditingController(text: '13.0827');
    final lonCtrl = TextEditingController(text: '80.2707');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F1B2C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        title: const Text(
          'Save New Location',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'City Name (e.g. Chennai)',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFFCD00)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: latCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Latitude',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: lonCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Longitude',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final lat = double.tryParse(latCtrl.text.trim()) ?? 0.0;
              final lon = double.tryParse(lonCtrl.text.trim()) ?? 0.0;
              if (name.isNotEmpty) {
                Navigator.of(ctx).pop();
                final created = await _apiService.addSavedLocation(
                  _apiService.defaultUserId,
                  name,
                  lat,
                  lon,
                );
                if (created != null && mounted) {
                  _loadSavedLocations();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFCD00),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'SAVE',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _loadSavedLocations,
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

                const SizedBox(height: 20),

                // Search Bar
                GlassmorphicContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  borderRadius: 24,
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  borderColor: Colors.white.withValues(alpha: 0.09),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search cities, airports...',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white.withValues(alpha: 0.4),
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                // Section 1: CURRENT LOCATION
                Text(
                  'CURRENT LOCATION',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),

                const SizedBox(height: 12),

                // Current Location Card
                GlassmorphicContainer(
                  padding: const EdgeInsets.all(20),
                  borderRadius: 22,
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  borderColor: Colors.white.withValues(alpha: 0.08),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Transform.rotate(
                                angle: -0.6,
                                child: const Icon(
                                  Icons.navigation,
                                  color: Color(0xFF67B7D1),
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Bengaluru',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Partly Cloudy',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.55),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: const [
                          Text(
                            '28°',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.wb_sunny_outlined,
                            color: Color(0xFFFFCD00),
                            size: 28,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                // Section 2: UPCOMING TRIP
                Text(
                  'UPCOMING TRIP',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),

                const SizedBox(height: 12),

                // Upcoming Trip Card
                GlassmorphicContainer(
                  padding: const EdgeInsets.all(20),
                  borderRadius: 22,
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  borderColor: Colors.white.withValues(alpha: 0.08),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'DEC 12 - DEC 18',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                          Transform.rotate(
                            angle: 0.5,
                            child: Icon(
                              Icons.flight,
                              color: Colors.white.withValues(alpha: 0.7),
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Paris, France',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Text(
                            'Expected',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.water_drop,
                            color: Color(0xFF67B7D1),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '8° / 3°',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                // Section 3: SAVED LOCATIONS with + action button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SAVED LOCATIONS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white70,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: _showAddLocationDialog,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Saved Locations List
                ..._savedLocations.map((loc) => _buildSavedLocationItem(loc)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSavedLocationItem(SavedLocationModel loc) {
    IconData weatherIcon = Icons.cloud_outlined;
    Color iconColor = Colors.white70;

    if ((loc.condition ?? '').toLowerCase().contains('night')) {
      weatherIcon = Icons.nightlight_round;
      iconColor = const Color(0xFF67B7D1);
    } else if ((loc.condition ?? '').toLowerCase().contains('sun')) {
      weatherIcon = Icons.wb_sunny_outlined;
      iconColor = const Color(0xFFFFCD00);
    }

    return GlassmorphicContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      borderRadius: 20,
      backgroundColor: Colors.white.withValues(alpha: 0.05),
      borderColor: Colors.white.withValues(alpha: 0.08),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                loc.localTime ?? '12:00 PM',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(weatherIcon, color: iconColor, size: 20),
              const SizedBox(width: 14),
              Text(
                '${loc.currentTempC?.toInt() ?? 20}°',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
