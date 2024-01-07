import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:parkinsons/pages/about_page.dart';
import 'package:parkinsons/pages/signup_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _key = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  Future<void> _login() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      User? user = userCredential.user;
      print('User logged in: ${user?.uid}');

      DatabaseReference userRef =
          FirebaseDatabase.instance.ref().child('users').child(user?.uid ?? '');

      // Fetch user details from the database and update the email
      DatabaseEvent dataSnapshotEvent =
          await userRef.child('user_details').once();

// Check if the event has data
      if (dataSnapshotEvent.snapshot.value != null) {
        // Extract the DataSnapshot from the event
        DataSnapshot dataSnapshot = dataSnapshotEvent.snapshot;

        // Now you can use the dataSnapshot
        Map<String, dynamic>? userDetails =
            dataSnapshot.value as Map<String, dynamic>?;

        if (userDetails != null) {
          userDetails['email'] = _emailController.text;
          await userRef.child('user_details').update(userDetails);
        }
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AboutPage()),
      );
    } catch (e) {
      print('Error during login: $e');

      if (e is FirebaseAuthException) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: An unexpected error occurred'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xff059D39),
              const Color(0xffE1E8E0).withOpacity(0.84),
            ],
          ),
        ),
        child: Padding(
          padding:
              const EdgeInsets.only(left: 16, top: 51, right: 16, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png', // Replace with the actual path to your logo
                width: 94,
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Welcome to',
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xff1A279A),
                ),
              ),
              Text(
                'ParkiSense',
                style: TextStyle(
                  fontSize: 32,
                  color: Color(0xff1A279A),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 40.0),
              Form(
                key: _key,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Color(0xffD9D9D9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextFormField(
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email or mobile number';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Email or Mobile Number',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Color(0xffD9D9D9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () {
                        if (_key.currentState?.validate() ?? false) {
                          _login();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16.0),
                        backgroundColor: const Color(0xFF1B2AB1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 18.0, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10.0),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignUpPage()),
                      );
                    },
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
