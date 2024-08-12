import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static const routeName = '/login';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLoading = false;
  bool _isRegistration = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (_isRegistration) {
          // Create new user
          UserCredential userCredential =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
          String newProfileId = FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .collection('profiles')
              .doc()
              .id;

          // Update user profile with name
          await userCredential.user
              ?.updateDisplayName(_nameController.text.trim());
          // Create a document in the users collection
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'uid': userCredential.user!.uid,
            'email': _emailController.text.trim(),
            'name': _nameController.text.trim(),
            'joined': FieldValue.serverTimestamp(),
            'last_selected_profile': newProfileId,
          });
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .collection('profiles')
              .doc(newProfileId)
              .set({
            'id': newProfileId,
            'userRef': userCredential.user!.uid,
            'name': 'Default',
            'created': FieldValue.serverTimestamp(),
            'isDefault': true
          });
        } else {
          // Login existing user
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
        }
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
        setState(() {
          _isLoading = false;
        });
      } finally {
        // setState(() {
        //   _isLoading = false;
        // });
      }
    }
  }

  void _toggleMode() {
    setState(() {
      _isRegistration = !_isRegistration;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(_isRegistration ? 'Sign Up' : 'Login')),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blueAccent,
                Colors.deepPurple
              ], // Change these colors as desired
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Image.asset(
                    'assets/images/logo_white.png',
                    height: 175,
                    width: 175,
                  ),
                  const SizedBox(height: 30),
                  if (_isRegistration)
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors
                                  .white), // White border when not focused
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white,
                              width: 2), // White thicker border when focused
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        labelStyle: TextStyle(color: Colors.white),
                        hintStyle: TextStyle(color: Colors.white70),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                      style: TextStyle(color: Colors.white),
                    ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color:
                                Colors.white), // White border when not focused
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      labelStyle: TextStyle(color: Colors.white),
                      hintStyle: TextStyle(color: Colors.white70),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                    style: TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color:
                                Colors.white), // White border when not focused
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white,
                            width: 2), // White thicker border when focused
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      labelStyle: TextStyle(color: Colors.white),
                      hintStyle: TextStyle(color: Colors.white70),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : Column(
                          children: [
                            ElevatedButton(
                              onPressed: _submitForm,
                              child:
                                  Text(_isRegistration ? 'Sign Up' : 'Login'),
                            ),
                            TextButton(
                              onPressed: _toggleMode,
                              child: Text(
                                _isRegistration
                                    ? 'Already have an account? Login'
                                    : 'Don\'t have an account? Sign Up',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
