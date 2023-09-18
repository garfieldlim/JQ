import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:glassmorphism/glassmorphism.dart';
import 'package:jq_admin/widgets/glassmorphic.dart';

import 'upserting.dart';

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
      backgroundColor: Color(0xff729482),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(35.0),
              child: Form(
                key: _formKey,
                child: GlassmorphicContainerWidget(
                  widthPercentage: 0.8,
                  heightPercentage: 0.8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Image(
                          image: NetworkImage('assets/try.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                                width: 250,
                                child: Image(
                                    image: NetworkImage('assets/jq.png'))),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 70.0, right: 70.0, top: 20.0),
                              child: TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  hintText: 'Enter your email',
                                  hintStyle:
                                      TextStyle(color: Color(0xffaebb8f)),
                                  labelText: 'Email',
                                  labelStyle:
                                      TextStyle(color: Color(0xffaebb8f)),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color(0xffe7d192), width: 2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color(0xffe7d192), width: 2),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  _email = value;
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 70.0, right: 70.0, top: 20.0),
                              child: TextFormField(
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'Enter your password',
                                  hintStyle:
                                      TextStyle(color: Color(0xffaebb8f)),
                                  labelText: 'Password',
                                  labelStyle:
                                      TextStyle(color: Color(0xffaebb8f)),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide(
                                        color: Color(0xffe7d192), width: 2),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color(0xffe7d192), width: 2),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  _password = value;
                                },
                              ),
                            ),
                            SizedBox(height: 20),
                            CupertinoButton(
                              color: Color(0xffaebb8f),
                              borderRadius: BorderRadius.circular(30),
                              child: Text('Login',
                                  style: TextStyle(color: Color(0xffe7d192))),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    final userCredentials =
                                        await _auth.signInWithEmailAndPassword(
                                      email: _email,
                                      password: _password,
                                    );

                                    if (userCredentials.user != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                UpsertingPage()),
                                      );
                                    } else {
                                      print(
                                          'Login failed. User credentials are null.');
                                    }
                                  } catch (e) {
                                    print('Login failed: $e');
                                  }
                                }
                              },
                            ),
                          ],
                        ),
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
