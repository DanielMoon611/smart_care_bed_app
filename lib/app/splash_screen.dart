import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white, // 배경색 지정 가능
        body: Center(
          child: Image.asset(
            'assets/loading.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}