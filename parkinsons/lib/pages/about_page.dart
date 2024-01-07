import 'package:flutter/material.dart';
import 'package:parkinsons/pages/finger_capture_page.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('AboutPage started'); // Debug statement

    return Scaffold(
      appBar: AppBar(
        title: const Text('About ParkiSense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        height: 50.0,
                      ),
                      const SizedBox(width: 8.0),
                      const Text(
                        'ParkiSense',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            const Text(
              'ParkiSense',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'is an app that detects Parkinson’s Disease at early stages using 3 easy steps and other symptoms.',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Parkinson’s Disease',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),
            const Text(
              'Parkinson\'s disease is a progressive disorder that affects the nervous system and the parts of the body controlled by the nerves. Symptoms start slowly. The first symptom may be a barely noticeable tremor in just one hand. Tremors are common, but the disorder may also cause stiffness or slowing of movement. Learn More.',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 20.0),
            GestureDetector(
              onTap: () {
                print('Button clicked'); // Debug statement
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CaptureUserInputPage()),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2AB1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.brightness_1,
                      color: Colors.white,
                      size: 16.0,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      'Test yourself with 3 easy steps',
                      style: TextStyle(fontSize: 18.0, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
