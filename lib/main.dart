import 'app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'dart:async';
import 'core/platform/orientation.dart';

// 전역 상태/스토리지
import 'value.dart';
import 'core/storage.dart';
import 'network/ble_service.dart';
import 'package:smart_care_bed_app/app/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!Platform.isIOS) {
    await DeviceOrientationController.rotateToLandscape();
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const SplashScreen());

  // ✅ 저장된 usercheck 값 복원
  usercheck = await AppStorage.loadUserCheck();
  userRecognitionEnabled.value = usercheck == 1;

  // ✅ 저장된 BLE 기기 자동 연결 시도
  lastConnectedDeviceId = await AppStorage.loadLastBleId();
  if (lastConnectedDeviceId != null) {
    try {
      await BleService.I.connect(lastConnectedDeviceId!);
      // await Future.delayed(const Duration(milliseconds: 300));
      // final initStatus = await BleService.I.readStatus(); 
      // if (initStatus == "FUNC_1") {
      //   isPauseFocused.value = true;
      // }

      // ✅ "FUNC_1"이 오는지 5초간 대기
      final completer = Completer<void>();
      late StreamSubscription<String> sub;

      sub = BleService.I.rxText$.listen((text) {
        final clean = text.trim();

        const validModes = {
          "BPD", "STD1", "STD2", "STD3",
          "MSG1/LV1", "MSG1/LV2", "MSG1/LV3",
          "MSG2/LV1", "MSG2/LV2", "MSG2/LV3",
          "MSG3/LV1", "MSG3/LV2", "MSG3/LV3",
          "MSG4/LV1", "MSG4/LV2", "MSG4/LV3",
          "MSG5/LV1", "MSG5/LV2", "MSG5/LV3",
          "MSG6/LV1", "MSG6/LV2", "MSG6/LV3",
          "CARE1", "CARE2", "LEFT", "RIGHT",
        };

        if (validModes.contains(clean)) {
          activeMode.value = false;
          isPauseFocused.value = false;
          selectedMode.value = clean;
          completer.complete();
          sub.cancel();
        }
      });

      // 5초 안에 이벤트 안 오면 그냥 화면 표시
      await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          sub.cancel();
          return;
        },
      );
    } catch (e) {
      debugPrint("자동 연결 실패: $e");
      await Future.delayed(const Duration(seconds: 5));
    }
  } else {
    // 연결할 기기 없으면 최소 5초는 스플래시 유지
    await Future.delayed(const Duration(seconds: 5));
  }

  runApp(const AppRoot());
}