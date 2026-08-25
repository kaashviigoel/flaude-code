import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mausam/screens/home.dart';

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key});

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  String? selectedMode = 'FITNESS'; // Default selection from screenshot

  final List<Map<String, dynamic>> modes = [
    {
      'id': 'HEALTH',
      'label': 'HEALTH',
      'icon': Icons.favorite_border,
    },
    {
      'id': 'FITNESS',
      'label': 'FITNESS',
      'icon': Icons.directions_run,
    },
    {
      'id': 'BEACH',
      'label': 'BEACH & SURF',
      'icon': Icons.waves, // Representing beach/waves
    },
    {
      'id': 'TRAVEL',
      'label': 'TRAVEL',
      'icon': Icons.flight,
    },
    {
      'id': 'FAMILY',
      'label': 'FAMILY',
      'icon': Icons.people_outline,
    },
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
    {
      'id': 'EVENTS',
      'label': 'EVENTS',
      'icon': Icons.calendar_month_outlined,
    },
  ];

  void _handleContinue() {
    // Navigate to Home Dashboard Screen
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            HomeScreen(selectedMode: selectedMode),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
      (route) => false, // Clear navigation stack
    );
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = const Color(0xFFFFCD00); // Gold Yellow Accent

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                // Screen Title
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
                // Subtitle
                Text(
                  'Select a mode to personalize your\nweather experience.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.55),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 40),

                // Grid of Options
                Expanded(
                  child: GridView.builder(
                    itemCount: modes.length,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                            // Main Card Container
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withOpacity(0.06)
                                    : Colors.white.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? accentColor
                                      : Colors.white.withOpacity(0.08),
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    mode['icon'],
                                    color: isSelected ? accentColor : Colors.white70,
                                    size: 28,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    mode['label'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      letterSpacing: 1.5,
                                      color: isSelected ? Colors.white : Colors.white60,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Yellow Checkmark Badge
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

                const SizedBox(height: 20),

                // Bottom Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // SKIP Button
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
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ),

                    // CONTINUE Button
                    SizedBox(
                      height: 52,
                      width: 160,
                      child: ElevatedButton(
                        onPressed: _handleContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.08),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.12),
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
                            Icon(
                              Icons.arrow_forward,
                              size: 16,
                            ),
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
