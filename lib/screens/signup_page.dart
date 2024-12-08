import 'package:elective/reusable/reuseable.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isTermsAccepted = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 600,
                minHeight: screenSize.height - 40,
              ),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: screenSize.height * 0.02),
                    const Text(
                      'Create a New Account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Email, username and password fields
                    Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        children: [
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.blue[50],
                              hintText: 'Enter your email address',
                              suffixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.blue[50],
                              hintText: 'Enter your username',
                              suffixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Dropdown for selecting user role
                          DropdownButtonFormField<String>(
                            value: _selectedRole,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.blue[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: 'Admin & Finance',
                                  child: Text('Admin & Finance')),
                              DropdownMenuItem(
                                  value: 'Operational',
                                  child: Text('Operational')),
                              DropdownMenuItem(
                                  value: 'Engineering',
                                  child: Text('Engineering')),
                              DropdownMenuItem(
                                  value: 'Institutional',
                                  child: Text('Institutional')),
                            ],
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedRole = newValue!;
                              });
                            },
                          ),
                          const SizedBox(height: 24),

                          TextField(
                            obscureText: !_isPasswordVisible,
                            controller: _passwordController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.blue[50],
                              hintText: 'Enter your Password',
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
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            obscureText: !_isConfirmPasswordVisible,
                            controller: _confirmPasswordController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.blue[50],
                              hintText: 'Confirm your Password',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Terms and Conditions Checkbox
                          Row(
                            children: [
                              Checkbox(
                                value: _isTermsAccepted,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _isTermsAccepted = value ?? false;
                                  });
                                },
                              ),
                              const Text('I agree to the '),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title:
                                            const Text('Terms and Conditions'),
                                        content: const SingleChildScrollView(
                                          child: Text(
                                            'By using the services provided by the PaperTrail, you agree to comply with and be bound by the following Terms and Conditions. These Terms govern your use of the System, which is designed to organize files, scan images, and convert them into PDF format.\n\n'
                                            'Please read these Terms carefully. If you do not agree to these Terms, do not use the Service.\n\n'
                                            '1. Acceptance of Terms\n'
                                            'By accessing or using the Service, you confirm that you have read, understood, and agree to be bound by these Terms and Conditions. If you do not agree, you must not use the Service.\n\n'
                                            '2. User Responsibilities\n'
                                            'You agree to:\n'
                                            '- Use the Service only for lawful purposes and in accordance with these Terms.\n'
                                            '- Ensure that the files, images, and documents you upload to the System do not infringe on any third-party intellectual property rights.\n'
                                            '- Not use the Service to upload, scan, or distribute any content that is illegal, harmful, or otherwise prohibited by applicable laws or regulations.\n\n'
                                            '3. Account Registration and Security\n'
                                            'If you register for an account to use the Service:\n'
                                            'You agree to provide accurate and complete information during the registration process.\n'
                                            '-You are responsible for maintaining the confidentiality of your account information, including your password.\n'
                                            'You agree to notify us immediately of any unauthorized use of your account.\n\n'
                                            '4. Intellectual Property Rights\n'
                                            'The System and all related content, including text, graphics, images, and software, are owned by or licensed to the System owner and are protected by copyright, trademark, and other intellectual property laws.\n'
                                            'You are granted a non-exclusive, non-transferable license to use the Service solely for personal or business purposes, in accordance with these Terms.\n\n'
                                            '5. Privacy and Data Collection\n'
                                            'The use of the Service may involve the collection of personal data, such as your contact information, files, and scanning data.\n'
                                            'By using the Service, you consent to our collection, use, and processing of your data as described in our Privacy Policy.\n\n'
                                            '6. Termination\n'
                                            'We may suspend or terminate your access to the Service, with or without cause, and with or without notice, if we believe that you have violated these Terms or for any other reason at our discretion.\n\n'
                                            'By using the System, you acknowledge that you have read, understood, and agree to these Terms and Conditions.',
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Close'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: const Text(
                                  'Terms and Conditions',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Sign up button
                          Center(
                            child: myButton2(
                              context,
                              'Sign Up',
                              () async {
                                if (!_isTermsAccepted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'You must agree to the terms and conditions to sign up.')),
                                  );
                                  return;
                                }

                                if (_passwordController.text !=
                                    _confirmPasswordController.text) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Passwords do not match!')),
                                  );
                                  return;
                                }

                                try {
                                  // Create user account
                                  final userCredential = await FirebaseAuth
                                      .instance
                                      .createUserWithEmailAndPassword(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text.trim(),
                                  );

                                  // Send verification email
                                  await userCredential.user
                                      ?.sendEmailVerification();

                                  // Store initial user details in Firestore
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userCredential.user!.uid)
                                      .set({
                                    'username': _usernameController.text.trim(),
                                    'email': _emailController.text.trim(),
                                    'role': _selectedRole,
                                    'emailVerified': false,
                                  });

                                  // Sign out the user after account creation
                                  await FirebaseAuth.instance.signOut();

                                  if (mounted) {
                                    // Show verification dialog with resend option
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title:
                                              const Text('Verify Your Email'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                'A verification link has been sent to your email.\n\n'
                                                '1. Please check your email (and spam folder)\n'
                                                '2. Click the verification link\n'
                                                '3. Return to the login page and sign in',
                                                textAlign: TextAlign.left,
                                              ),
                                              const SizedBox(height: 20),
                                              TextButton(
                                                onPressed: () async {
                                                  try {
                                                    await FirebaseAuth
                                                        .instance.currentUser
                                                        ?.sendEmailVerification();
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                          content: Text(
                                                              'Verification email resent!')),
                                                    );
                                                  } catch (e) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                          content: Text(
                                                              'Error resending verification email')),
                                                    );
                                                  }
                                                },
                                                child: const Text(
                                                    'Resend Verification Email'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  Navigator.pushNamedAndRemoveUntil(
                                                      context, '/', (route) => false);
                                                },
                                                child:
                                                    const Text('Go to Login'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  }
                                } on FirebaseAuthException catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            e.message ?? 'An error occurred')),
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Sign in link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already have an account? ',
                                style: TextStyle(color: Colors.black54),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, '/', (route) => false);
                                },
                                child: const Text(
                                  'Sign in',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}
