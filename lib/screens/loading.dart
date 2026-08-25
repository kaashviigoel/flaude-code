import 'dart:async';

import 'package:flutter/material.dart';
import 'onboarding.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101820),
      body: Center(
        child: SizedBox(
          width: 393,
          height: 852,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.00, 0.50),
                  end: Alignment(1.00, 0.50),
                  colors: [Color(0xFF101820), Color(0xFF213142)],
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const Positioned(
                    left: -11,
                    top: 441,
                    child: SizedBox(width: 416, height: 82),
                  ),
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 300,
                      fit: BoxFit.contain,
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
}
