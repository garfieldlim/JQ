import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
      backgroundColor: const Color(0xffAFBC8F),
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
                  color2: const Color(0xffafbc8f),
                  color1: const Color(0xffafbc8f),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                            Image.asset('web/assets/logo.gif',
                                width: 400, height: 400),
                            // Padding(
                            //   padding:
                            //       const EdgeInsets.only(left: 20.0, right: 20),
                            //   child: Text(
                            //     'Josenian Quiri: A Virtual Assistant for USJ-R',
                            //     style: TextStyle(
                            //         fontSize: 24,
                            //         color: Color(0xff729482),
                            //         fontWeight: FontWeight.bold),
                            //   ),
                            // ),
                          ])),
                      Expanded(
                        child: Container(
                          color: const Color(0xffE7D192),
                          child: Column(
                            children: <Widget>[
                              const SizedBox(height: 45),
                              const SizedBox(
                                width: 300,
                                child: Image(
                                  image: NetworkImage('assets/jq.png'),
                                ),
                              ),
                              const SizedBox(height: 54),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 70.0, right: 70.0, top: 20.0),
                                child: TextFormField(
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color(0xffebd79c),
                                    hintText: 'Enter your email',
                                    hintStyle: const TextStyle(color: Colors.white),
                                    labelText: 'Email',
                                    labelStyle: const TextStyle(color: Colors.white),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                      borderSide: const BorderSide(
                                        color: Color(0xffebd79c),
                                        width: 2,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                      borderSide: const BorderSide(
                                          color: Colors.transparent, width: 2),
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
                                padding: const EdgeInsets.only(
                                    left: 70.0, right: 70.0, top: 20.0),
                                child: TextFormField(
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color(0xffebd79c),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    hintText: 'Enter your password',
                                    hintStyle: const TextStyle(color: Colors.white),
                                    labelText: 'Password',
                                    labelStyle: const TextStyle(color: Colors.white),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                      borderSide: const BorderSide(
                                          color: Color(0xfff3e4b0), width: 2),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                      borderSide: const BorderSide(
                                          color: Colors.transparent, width: 2),
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
                              const SizedBox(height: 45),
                              CupertinoButton(
                                color: const Color(0xff729482),
                                borderRadius: BorderRadius.circular(30),
                                child: const Text('Login',
                                    style: TextStyle(color: Color(0xffe7d192))),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    try {
                                      final userCredentials = await _auth
                                          .signInWithEmailAndPassword(
                                        email: _email,
                                        password: _password,
                                      );

                                      if (userCredentials.user != null) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const UpsertingPage()),
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
