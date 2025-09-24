import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// --------------------
// BLE 통신 관련 상수
// --------------------
const kManufacturerId = 0x00E0;
const kDisappearAfter = Duration(seconds: 5);
const kFixedName = 'Smart Care Bed';

final Guid serviceUuid = Guid('12345678-1234-5678-1234-56789abc0000');
final Guid rxUuid      = Guid('12345678-1234-5678-1234-56789abc0001');
final Guid txUuid      = Guid('12345678-1234-5678-1234-56789abc0002');

// --------------------
// 앱 전역 상태 값
// --------------------
int usercheck = 0;
String mode = '';

final ValueNotifier<bool> activeMode = ValueNotifier<bool>(true);
final ValueNotifier<bool> userRecognitionEnabled = ValueNotifier<bool>(false);

// 최근 연결된 BLE 장치 ID (자동 연결용)
String? lastConnectedDeviceId;
String? lastConnectedStableId;

// --------------------
// ✅ 패널 상태 (전역 관리)
// --------------------
final ValueNotifier<bool> isPauseFocused = ValueNotifier<bool>(false);
final ValueNotifier<int> heatLevel = ValueNotifier<int>(0);
final ValueNotifier<int> fanLevel = ValueNotifier<int>(0);
final ValueNotifier<bool> isCprClicked = ValueNotifier<bool>(false);

final ValueNotifier<bool> isToggleFocused = ValueNotifier<bool>(false);
final GlobalKey<ScaffoldMessengerState> globalMessengerKey = GlobalKey<ScaffoldMessengerState>();