// splash_screen.dart

import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  final Function onSplashFinished;

  const SplashScreen({super.key, required this.onSplashFinished});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 4), () {
      // Simulate a delay for 4 seconds (as in your SplashScreen)
      print("Splash screen finished");
      onSplashFinished(); // Call the callback
    });

    return Scaffold(
      backgroundColor: Colors.green[700],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Welcome to',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'ParkiSense',
              style: TextStyle(
                color: Color(0xFF1A279A),
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0),
            Image.asset(
              'assets/logo.png',
              height: 250.0,
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Empowering Tomorrow,',
              style: TextStyle(
                color: Color.fromARGB(255, 15, 15, 15),
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 2.0),
            const Text(
              'Detecting Today',
              style: TextStyle(
                color: Color.fromARGB(255, 15, 15, 15),
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Your early warning system for',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2.0),
            const Text(
              'Parkinson\'s with ParkinSense',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
