import 'package:elective/screens/login_page.dart';
import 'package:elective/screens/main_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class Authentication extends StatelessWidget {
  const Authentication({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.hasData) {
            final user = snapshot.data!;
            
            if (!user.emailVerified) {
              FirebaseAuth.instance.signOut();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Email Not Verified: Please verify your email before logging in.'),
                  backgroundColor: Colors.red,
                ),
              );
              return const LoginPage();
            }
            
            return const MainNavigation();
          }

          return const LoginPage();
        },
      ),
    );
  }
}
