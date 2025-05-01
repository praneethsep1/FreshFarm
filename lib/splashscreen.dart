import 'package:farmfresh/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'main.dart';

/// A stateful widget that displays the app's splash screen.
///
/// Shows a logo and app branding for a brief duration before navigating to the
/// [WelcomeScreen].

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

/// The state class for [SplashScreen].
///
/// Manages the splash screen's initialization and navigation to the [WelcomeScreen]
/// after a delay.

class _SplashScreenState extends State<SplashScreen> {

  /// Initializes the splash screen and schedules navigation to [WelcomeScreen].
  ///
  /// Sets a 3-second delay before replacing the current route with [WelcomeScreen].
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    });
  }

  /// Builds the UI for the splash screen.
  ///
  /// Displays a gradient background with the app's logo, name, and tagline centered
  /// on the screen.
  ///
  /// Parameters:
  ///   - context: The [BuildContext] for building the widget.
  ///
  /// Returns:
  ///   A [Widget] representing the splash screen UI.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/farm-fresh-logo.svg',
                width: 150,
              ),
              const SizedBox(height: 20),
              const Text(
                'Farm Fresh',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'From Farm to Table',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
