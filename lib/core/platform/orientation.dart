import 'package:flutter/services.dart';
import 'dart:developer';
import 'dart:io' show Platform;

class DeviceOrientationController {
  static const MethodChannel _channel = MethodChannel('device_orientation');

  static Future<void> rotateToLandscape() async {
    if (Platform.isIOS) return;
    try {
      await _channel.invokeMethod('setLandscape');
    } catch (e) {
      log("rotateToLandscape failed: $e", name: 'ControlPanel');
    }
  }
}
