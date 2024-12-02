import 'package:elective/reusable/reuseable.dart';
import 'package:flutter/material.dart';

class GetStarted extends StatelessWidget {
  const GetStarted({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 200),
                Center(child: logoWidget('lib/assets/logo.png', 300, 300)),
                const SizedBox(height: 20),
                Center(child: myButton2(
                  context,
                  'Get Started',
                  () {
                    Navigator.pushNamed(context, '/login');
                  },
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}