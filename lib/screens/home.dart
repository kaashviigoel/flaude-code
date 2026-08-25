import 'dart:ui';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String? selectedMode;

  const HomeScreen({
    super.key,
    this.selectedMode,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = const Color(0xFFFFCD00); // Gold Accent

    // Dynamic advice based on user's selected mode
    final modeData = _getModeAdvisory(selectedMode ?? 'GENERAL');

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.3,
            colors: [
              Color(0xFF1E3354), // Deep indigo/blue glow
              Color(0xFF0F1B2C), // Very dark navy
              Color(0xFF070B12), // Premium dark gray-black
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Bar / Top Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'San Francisco',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tuesday, Aug 25',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                      
                      // Selected Mode Badge
                      if (selectedMode != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                modeData['icon'] as IconData,
                                color: accentColor,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                selectedMode!,
                                style: TextStyle(
                                  color: accentColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 36),

                  // Hero Temp Section
                  Center(
                    child: Column(
                      children: [
                        Image.network(
                          'https://images.unsplash.com/photo-1592217643561-2e386e915a2d?auto=format&fit=crop&w=150&q=80',
                          width: 80,
                          height: 80,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.wb_sunny_outlined,
                            size: 72,
                            color: Colors.orangeAccent,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '72°',
                          style: TextStyle(
                            fontSize: 76,
                            fontWeight: FontWeight.w200,
                            color: Colors.white,
                            height: 1.0,
                          ),
                        ),
                        const Text(
                          'PARTLY CLOUDY',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.0,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'H: 76°  L: 55°',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Dynamic Adaptive Advisory Card (Glassmorphic)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    modeData['icon'] as IconData,
                                    color: accentColor,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  modeData['title'] as String,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              modeData['description'] as String,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                            const Divider(
                              color: Colors.white10,
                              height: 24,
                            ),
                            const Text(
                              'RECOMMENDATIONS',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...(modeData['tips'] as List<String>).map(
                              (tip) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '• ',
                                      style: TextStyle(
                                        color: accentColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        tip,
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.65),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Hourly Forecast Section (Header)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Hourly Forecast',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'More details',
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Horizontal Forecast list
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: 6,
                      separatorBuilder: (context, index) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final hours = ['Now', '1 PM', '2 PM', '3 PM', '4 PM', '5 PM'];
                        final temps = ['72°', '74°', '75°', '73°', '71°', '68°'];
                        final icons = [
                          Icons.wb_cloudy_outlined,
                          Icons.wb_sunny_outlined,
                          Icons.wb_sunny_outlined,
                          Icons.wb_sunny_outlined,
                          Icons.wb_cloudy_outlined,
                          Icons.wb_cloudy_outlined
                        ];

                        return Container(
                          width: 76,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.02),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.04),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                hours[index],
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Icon(
                                icons[index],
                                color: accentColor,
                                size: 18,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                temps[index],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getModeAdvisory(String mode) {
    switch (mode) {
      case 'FITNESS':
        return {
          'title': 'Fitness Advisory',
          'icon': Icons.directions_run,
          'description': 'Ideal conditions for running and cycling. The UV index is moderate and humidity is at 42%. Wind speed is calm.',
          'tips': [
            'Optimal running temperature (between 50°F and 72°F).',
            'Wear sunscreen with SPF 30+ for outdoor workouts.',
            'Hydrate: Drink at least 8oz of water before starting.',
          ],
        };
      case 'HEALTH':
        return {
          'title': 'Health & Wellbeing Advisory',
          'icon': Icons.favorite_border,
          'description': 'Air Quality Index is Excellent (AQI 24). Grass pollen levels are low. Temperature is very comfortable for joint health.',
          'tips': [
            'Great day to air out the house and get fresh oxygen circulation.',
            'Perfect conditions for outdoor meditation or yoga.',
            'Low pollen levels: safe for asthma or allergy sufferers.',
          ],
        };
      case 'BEACH':
        return {
          'title': 'Beach & Surf Advisory',
          'icon': Icons.waves,
          'description': 'Warm air temp with a cool water temperature of 62°F. Wave height is 2-4 feet with slight chop.',
          'tips': [
            'Moderate rip current risk: swim near a lifeguard.',
            'UV index is high (7/10). Reapply sunscreen every 2 hours.',
            'Low tide is at 2:45 PM; perfect for beach walks.',
          ],
        };
      case 'TRAVEL':
        return {
          'title': 'Travel Advisory',
          'icon': Icons.flight,
          'description': 'Zero delays expected due to weather. Road visibility is 10 miles. Calm winds at airport terminal.',
          'tips': [
            'No flight delays or turbulent patterns expected.',
            'Great driving conditions on regional highways.',
            'Pack light layers: temperature will drop to 55°F by evening.',
          ],
        };
      case 'FAMILY':
        return {
          'title': 'Family Day Advisory',
          'icon': Icons.people_outline,
          'description': 'Excellent weather for park picnics, playground activities, or backyard barbeques. High temperature of 76°F.',
          'tips': [
            'Pack outdoor games: light wind will not disrupt play.',
            'Sunset is at 7:54 PM - plenty of daylight for family time.',
            'Bring light jackets for the kids for when the sun goes down.',
          ],
        };
      case 'AGRICULTURE':
        return {
          'title': 'Agriculture Advisory',
          'icon': Icons.agriculture_outlined,
          'description': 'Moderate soil moisture retention. No frost warning in the forecast. Rain probability is 0% for the next 48 hours.',
          'tips': [
            'Perfect conditions for harvesting and field mowing.',
            'Irrigate crops early morning to minimize evaporation loss.',
            'Good day for applying organic soil fertilizers.',
          ],
        };
      case 'COMMUTE':
        return {
          'title': 'Commuter Advisory',
          'icon': Icons.directions_car_filled_outlined,
          'description': 'Clear roads with normal dry traction conditions. Visibility is excellent. Expect minor solar glare during sunset.',
          'tips': [
            'No road hazards, surface wetness, or fog blocks.',
            'Wear polarized sunglasses to combat sunset glare.',
            'Good fuel efficiency conditions (steady air pressure).',
          ],
        };
      case 'EVENTS':
        return {
          'title': 'Events Planning Advisory',
          'icon': Icons.calendar_month_outlined,
          'description': 'Outdoor events are highly recommended. Zero precipitation risk. Wind gust speeds are below 8 mph.',
          'tips': [
            'No tents or covers required for wind or rain protection.',
            'Set up outdoor sound systems safely (humidity is low).',
            'Excellent photo-shoot lighting conditions in late afternoon.',
          ],
        };
      default:
        return {
          'title': 'General Weather Advisory',
          'icon': Icons.wb_sunny_outlined,
          'description': 'Comfortable conditions with a mixture of sun and clouds. Plan your day normally.',
          'tips': [
            'Keep an umbrella handy in your car just in case.',
            'Check the local UV index map before heading out.',
            'Enjoy the pleasant afternoon temperatures.',
          ],
        };
    }
  }
}
