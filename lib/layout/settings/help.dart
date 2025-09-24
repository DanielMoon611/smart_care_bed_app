import 'package:flutter/material.dart';
import 'package:smart_care_bed_app/app/routes.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: '설정으로',
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(AppRoutes.setup);
          },
        ),
        title: const Text('고객센터 연결'),
      ),
      body: const Center(
        child: Text(
          '고객센터 연결 화면',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}