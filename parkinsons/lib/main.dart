// ignore_for_file: unused_import

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:parkinsons/pages/login_page.dart';
import 'pages/about_page.dart'; // Assuming you have a file for the About Page
import 'pages/splash_screen.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCa_9ZJPKiOxetkN5wo4pnlX8xbr0umsGg",
      appId: "1:435331385958:android:711e87c5d7182632b03ba7",
      messagingSenderId: "435331385958",
      projectId: "disease-81908",
      databaseURL: "https://disease-81908-default-rtdb.firebaseio.com/",
      storageBucket: "gs://disease-81908.appspot.com",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashContainer(),
    );
  }
}

class SplashContainer extends StatefulWidget {
  const SplashContainer({Key? key}) : super(key: key);

  @override
  _SplashContainerState createState() => _SplashContainerState();
}

class _SplashContainerState extends State<SplashContainer> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      // You might want to add your splash screen content here
      onSplashFinished: () {},
    );
  }
}
