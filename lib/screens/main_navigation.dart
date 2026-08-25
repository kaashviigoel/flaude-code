import 'package:flutter/material.dart';
import 'package:mausam/screens/alerts.dart';
import 'package:mausam/screens/home.dart';
import 'package:mausam/screens/maps.dart';
import 'package:mausam/screens/persona_view.dart';
import 'package:mausam/widgets/bottom_nav_bar.dart';

class MainNavigationScreen extends StatefulWidget {
  final String? initialPersona;
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialPersona,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(selectedMode: widget.initialPersona),
      const AlertsScreen(),
      const MapsScreen(),
      PersonaViewScreen(selectedMode: widget.initialPersona),
    ];

    return Scaffold(
      extendBody: true,
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
        child: IndexedStack(index: _currentIndex, children: screens),
      ),
      bottomNavigationBar: MausamBottomNavBar(
        currentIndex: _currentIndex,
        onTabSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
