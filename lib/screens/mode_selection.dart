import 'package:flutter/material.dart';
import 'package:mausam/models/user_profile.dart';
import 'package:mausam/screens/main_navigation.dart';
import 'package:mausam/services/weather_api.dart';

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key});

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  String? selectedMode = 'HEALTH';

  final List<Map<String, dynamic>> modes = [
    {'id': 'HEALTH', 'label': 'HEALTH', 'icon': Icons.favorite_border},
    {'id': 'FITNESS', 'label': 'FITNESS', 'icon': Icons.directions_run},
    {'id': 'BEACH', 'label': 'BEACH & SURF', 'icon': Icons.waves},
    {'id': 'TRAVEL', 'label': 'TRAVEL', 'icon': Icons.flight},
    {'id': 'FAMILY', 'label': 'FAMILY', 'icon': Icons.people_outline},
    {
      'id': 'AGRICULTURE',
      'label': 'AGRICULTURE',
      'icon': Icons.agriculture_outlined,
    },
    {
      'id': 'COMMUTE',
      'label': 'COMMUTE',
      'icon': Icons.directions_car_filled_outlined,
    },
    {'id': 'EVENTS', 'label': 'EVENTS', 'icon': Icons.calendar_month_outlined},
  ];

  void _handleContinue() {
    final persona = switch (selectedMode) {
      'FITNESS' => 'fitness',
      'HEALTH' => 'health',
      'TRAVEL' => 'traveller',
      'COMMUTE' => 'commuter',
      _ => 'health',
    };
    WeatherApiService().savePreferences(
      'demo-user',
      UserPreferences(persona: persona),
    );
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            MainNavigationScreen(initialPersona: selectedMode),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = const Color(0xFFFFCD00);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.3,
            colors: [Color(0xFF1E3354), Color(0xFF0F1B2C), Color(0xFF070B12)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'What matters most to\nyou?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Select a mode to personalize your\nweather experience.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.55),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 40),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 4, bottom: 20),
                      itemCount: modes.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.45,
                          ),
                      itemBuilder: (context, index) {
                        final mode = modes[index];
                        final isSelected = selectedMode == mode['id'];

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedMode = mode['id'];
                            });
                          },
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.06)
                                      : Colors.white.withValues(alpha: 0.03),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? accentColor
                                        : Colors.white.withValues(alpha: 0.08),
                                    width: isSelected ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      mode['icon'],
                                      color: isSelected
                                          ? accentColor
                                          : Colors.white70,
                                      size: 28,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      mode['label'],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        letterSpacing: 1.5,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.white60,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              if (isSelected)
                                Positioned(
                                  top: -6,
                                  right: -6,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: accentColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.black,
                                      size: 14,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedMode = null;
                        });
                        _handleContinue();
                      },
                      child: Text(
                        'SKIP',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2.0,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 52,
                      width: 160,
                      child: ElevatedButton(
                        onPressed: _handleContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.08),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.12),
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'CONTINUE',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2.0,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
