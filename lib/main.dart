import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mausam/screens/onboarding.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MausamApp());
}

class MausamApp extends StatelessWidget {
  const MausamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mausam',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Outfit',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF070B12),
      ),
      home: const OnboardingScreen(),
    );
  }
}
