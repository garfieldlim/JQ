import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:glassmorphism/glassmorphism.dart';

import 'homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 1500,
        decoration: BoxDecoration(
          image: DecorationImage(
            image:
                NetworkImage("assets/bg.png"), // Replace with your image file
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(35.0),
              child: Form(
                key: _formKey,
                child: GlassmorphicContainer(
                  width: 500,
                  height: 570,
                  borderRadius: 20,
                  blur: 20,
                  alignment: Alignment.bottomCenter,
                  border: 2,
                  linearGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFeeeeee).withOpacity(0.1),
                      Color(0xFFeeeeee).withOpacity(0.01),
                    ],
                    stops: [
                      0.1,
                      1,
                    ],
                  ),
                  borderGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFeeeeeee).withOpacity(0.5),
                      Color((0xFFeeeeeee)).withOpacity(0.5),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          width: 250,
                          child: Image(image: NetworkImage('assets/jq.png'))),
                      Padding(
                        padding: EdgeInsets.all(20.0),
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'Enter your email',
                            hintStyle: TextStyle(color: Colors.white),
                            labelText: 'Email',
                            labelStyle: TextStyle(color: Colors.white),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey), // This is the change
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey), // This is the change
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey), // This is the change
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            // Add more validation logic here if needed
                            return null;
                          },
                          onChanged: (value) {
                            _email = value;
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.all(20.0),
                        child: TextFormField(
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            hintStyle: TextStyle(color: Colors.white),
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Colors.white),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey), // This is the change
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey), // This is the change
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey), // This is the change
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            // Add more validation logic here if needed
                            return null;
                          },
                          onChanged: (value) {
                            _password = value;
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      CupertinoButton(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        child: Text('Login',
                            style: TextStyle(
                                color: Color.fromARGB(255, 255, 223, 107))),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // If the form is valid, proceed with login
                            try {
                              // Sign in the user with Firebase Authentication
                              final userCredentials =
                                  await _auth.signInWithEmailAndPassword(
                                email: _email,
                                password: _password,
                              );

                              if (userCredentials.user != null) {
                                // Login successful, navigate to the home page or any other desired page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UpsertingPage()),
                                );
                              } else {
                                // Handle login failure, show an error message if necessary
                                // For example: Show a snackbar or a dialog box with an error message
                                print(
                                    'Login failed. User credentials are null.');
                              }
                            } catch (e) {
                              // Handle login failure, show an error message if necessary
                              // For example: Show a snackbar or a dialog box with an error message
                              print('Login failed: $e');
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
