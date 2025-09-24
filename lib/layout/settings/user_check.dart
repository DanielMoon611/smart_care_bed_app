import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:smart_care_bed_app/app/routes.dart';
import 'package:smart_care_bed_app/value.dart';
import 'package:smart_care_bed_app/core/storage.dart';

class UserCheckPage extends StatelessWidget {
  const UserCheckPage({super.key});

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
        title: const Text('사용자 확인'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListTile(
          leading: const Icon(Icons.sensors, color: Colors.red),
          title: const Text('사용자 인식'),
          subtitle: const Text('사용자 인식 ON/OFF'),
          trailing: ValueListenableBuilder<bool>(
            valueListenable: userRecognitionEnabled,
            builder: (context, isOn, _) {
              return Switch(
                value: isOn,
                onChanged: (value) async {
                  userRecognitionEnabled.value = value;
                  usercheck = value ? 1 : 0;
                  await AppStorage.saveUserCheck(usercheck);
                  if (await Vibration.hasVibrator()) {
                    Vibration.vibrate(duration: 50);
                  }
                  log("사용자 인식: ${value ? "ON" : "OFF"} (usercheck=$usercheck)", name: 'UserCheckPage');
                },
              );
            },
          ),
        ),
      ),
    );
  }
}