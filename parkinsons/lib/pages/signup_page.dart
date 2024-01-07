import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:parkinsons/pages/login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _key = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
          padding: const EdgeInsets.only(
            left: 16,
            top: 63,
            right: 16,
            bottom: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1A279A),
                ),
              ),
              const SizedBox(height: 20.0),
              Form(
                key: _key,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xffD9D9D9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextFormField(
                        controller: usernameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a valid username';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Username',
                          prefixIcon: Icon(Icons.person),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xffD9D9D9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextFormField(
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xffD9D9D9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextFormField(
                        controller: mobileNumberController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a valid mobile number';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Mobile Number',
                          prefixIcon: Icon(Icons.phone),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xffD9D9D9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextFormField(
                        controller: ageController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a valid age';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Age',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xffD9D9D9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a valid password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () async {
                        if (_key.currentState?.validate() ?? false) {
                          try {
                            UserCredential userCredential = await FirebaseAuth
                                .instance
                                .createUserWithEmailAndPassword(
                              email: emailController.text,
                              password: passwordController.text,
                            );

                            // Get the current user after successful sign-up
                            User? user = userCredential.user;

                            // Generate a unique identifier for the user (you can use user.uid)
                            String userId = user?.uid ?? '';

                            // Save user details in Realtime Database
                            print('Saving user details to the database...');
                            print('Username: ${usernameController.text}');
                            print('Email: ${emailController.text}');
                            print('Phone: ${mobileNumberController.text}');
                            print('Age: ${ageController.text}');

                            await FirebaseDatabase.instance
                                .reference()
                                .child('users')
                                .child(userId)
                                .child('user_details')
                                .set({
                              'username': usernameController.text,
                              'email': emailController.text,
                              'phone': mobileNumberController.text,
                              'age': ageController.text,
                            });

                            // Print a success message along with the user ID
                            print(
                                'User signed up successfully. User ID: $userId');

                            // If sign-up is successful, navigate to the login screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()),
                            );
                          } catch (e) {
                            print('Error during sign up: $e');
                            // Handle sign-up errors here
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        backgroundColor: const Color(0xFF1B2AB1),
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(fontSize: 18.0, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account?',
                    style: TextStyle(
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Color(0xff1B2AB1),
                        fontSize: 16.0,
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
