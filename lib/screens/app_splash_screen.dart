import 'package:flutter/material.dart';

class AppSplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          padding: EdgeInsets.only(left:30, right:30),
          child: Container(
            child: Image.asset('assets/images/splashlogo.png'),
          ),
        ),
      ),
    );
  }
}
