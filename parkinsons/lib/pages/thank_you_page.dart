// thank_you_page.dart

import 'package:flutter/material.dart';

class ThankYouPage extends StatelessWidget {
  const ThankYouPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thank You Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Thank you for completing the tests!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to any other page as needed
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              child: const Text('Go Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
