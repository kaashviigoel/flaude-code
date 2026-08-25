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
                clipBehavior: Clip.antiAlias,
                children: [
                  // ------------------------------------------------
                  // Figma decorative image
                  // ------------------------------------------------
                  //
                  // Your Figma Dev Mode exported this as:
                  //
                  // NetworkImage("https://placehold.co/416x82")
                  //
                  // That is only a placeholder. We will replace
                  // this with your actual exported Figma asset.
                  //
                  Positioned(
                    left: -11,
                    top: 441,
                    child: SizedBox(width: 416, height: 82, child: Container()),
                  ),

                  // ------------------------------------------------
                  // Bottom circular shape
                  // ------------------------------------------------
                  Positioned(
                    left: 61,
                    top: 524,
                    child: Container(
                      width: 384,
                      height: 384,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00050B),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                  ),

                  // ------------------------------------------------
                  // MAUSAM logo
                  // ------------------------------------------------
                  //
                  // We'll put the actual logo here once we use
                  // the logo asset from your Figma.
                  //
                  Center(
                    child: Text(
                      'MAUSAM',
                      style: const TextStyle(
                        fontFamily: 'Josefin Sans',
                        fontSize: 32,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 3.2,
                        color: Color(0xFFF4F5F2),
                      ),
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
