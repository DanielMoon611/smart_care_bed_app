import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_care_bed_app/app/routes.dart';
import 'package:smart_care_bed_app/network/ble_service.dart';
import 'package:smart_care_bed_app/value.dart';

class ControlPanel extends StatefulWidget {
  const ControlPanel({super.key});

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  String? _activeRoute;
  StreamSubscription<String>? _rxSub;

  void _onCprLockChanged() {
    if (!CprLock.I.isLocked.value) {
      isCprClicked.value = false;
    }
  }

  @override
  void initState() {
    super.initState();
    CprLock.I.isLocked.addListener(_onCprLockChanged);

    _rxSub = BleService.I.rxText$.listen((text) {
      final clean = text.trim();

      const validModes = {
        "BPD", "STD1", "STD2", "STD3",
        "MSG1/LV1", "MSG1/LV2", "MSG1/LV3",
        "MSG2/LV1", "MSG2/LV2", "MSG2/LV3",
        "MSG3/LV1", "MSG3/LV2", "MSG3/LV3",
        "MSG4/LV1", "MSG4/LV2", "MSG4/LV3",
        "MSG5/LV1", "MSG5/LV2", "MSG5/LV3",
        "MSG6/LV1", "MSG6/LV2", "MSG6/LV3",
        "CARE1", "CARE2",
      };

      if (validModes.contains(clean)) {
        activeMode.value = false;
        isPauseFocused.value = false;
        selectedMode.value = clean;

        // // ✅ LEFT/RIGHT → CARE3 강제 진입
        // if (clean == "LEFT" || clean == "RIGHT") {
        //   selectedMode.value = "CARE3";
        //   WidgetsBinding.instance.addPostFrameCallback((_) {
        //     if (mounted) {
        //       Navigator.of(context).pushReplacementNamed(AppRoutes.patientCare);
        //     }
        //   });
        // }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() {});
        });
      }
    });
  }

  @override
  void dispose() {
    _rxSub?.cancel();
    CprLock.I.isLocked.removeListener(_onCprLockChanged);
    super.dispose();
  }

  void _goto(BuildContext context, String routeName) {
    if (isToggleFocused.value) {
      debugPrint("⚠️ left/right 버튼이 활성화되어 있어 화면 이동 불가");

      final m = globalMessengerKey.currentState;
      m?.hideCurrentSnackBar();
      m?.showSnackBar(
        const SnackBar(
          content: Text("이동 동작중입니다"),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(12, 0, 12, 12),
        ),
      );
      return;
    }
    setState(() {
      _activeRoute = routeName;
    });
    Navigator.of(context).pushReplacementNamed(routeName);
  }

  void _action() async {
    // ✅ 1. BLE 연결 여부 체크
    if (BleService.I.firstConnectedId == null) {
      // final m = globalMessengerKey.currentState;
      // m?.hideCurrentSnackBar();
      // m?.showSnackBar(
      //   const SnackBar(
      //     content: Text("침대를 연결해주세요"),
      //     duration: Duration(seconds: 2),
      //     behavior: SnackBarBehavior.floating,
      //     margin: EdgeInsets.fromLTRB(12, 0, 12, 12),
      //   ),
      // );
      // return;
      showCenterToast(context, "침대를 연결해주세요");
      return;
    }

    if (mode.isEmpty) {
      // final m = globalMessengerKey.currentState;
      // m?.hideCurrentSnackBar();
      // m?.showSnackBar(
      //   const SnackBar(
      //     content: Text("모드를 선택해주세요"),
      //     duration: Duration(seconds: 2),
      //     behavior: SnackBarBehavior.floating,
      //     margin: EdgeInsets.fromLTRB(12, 0, 12, 12),
      //   ),
      // );
      // return;
      showCenterToast(context, "모드를 선택해주세요");
      return;
    }

    if (isToggleFocused.value) {
      final m = globalMessengerKey.currentState;
      m?.hideCurrentSnackBar();
      m?.showSnackBar(
        const SnackBar(
          content: Text("이동 모드를 종료해주세요(현재 동작중인 버튼 다시 눌러 정지)"),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(12, 0, 12, 12),
        ),
      );
      return;
    }

    final oldValue = isPauseFocused.value;
    isPauseFocused.value = !oldValue;

    try {
      if (isPauseFocused.value) {
        await BleService.I.sendToAllConnected('PAUSE'.codeUnits);
      } else {
        await BleService.I.sendToAllConnected(selectedMode.value.codeUnits);
        activeMode.value = false;
      }
    } catch (e) {
      debugPrint("BLE send FAIL: $e");
      isPauseFocused.value = oldValue;
      if (!mounted) return;
      showCenterToast(context, "침대를 연결해주세요");
    }

    debugPrint(
      "PAUSE toggled -> ${isPauseFocused.value ? 'FOCUSED' : 'NORMAL'}",
    );
  }

  void _heat() {
    if (BleService.I.firstConnectedId == null) {
      showCenterToast(context, "침대를 연결해주세요");
      return;
    }
    heatLevel.value = (heatLevel.value + 1) % 4;
    debugPrint("온열 단계: ${heatLevel.value}");
  }

  void _fan() {
    if (BleService.I.firstConnectedId == null) {
      showCenterToast(context, "침대를 연결해주세요");
      return;
    }
    fanLevel.value = (fanLevel.value + 1) % 4;
    debugPrint("통풍 단계: ${fanLevel.value}");
  }

  void _cpr() async {
    if (BleService.I.firstConnectedId == null) {
      showCenterToast(context, "침대를 연결해주세요");
      return;
    }
    if (isToggleFocused.value) {
      final m = globalMessengerKey.currentState;
      m?.hideCurrentSnackBar();
      m?.showSnackBar(
        const SnackBar(
          content: Text("이동 모드를 종료해주세요(현재 동작중인 버튼 다시 눌러 정지)"),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(12, 0, 12, 12),
        ),
      );
      return;
    }
    await BleService.I.sendToAllConnected('INIT'.codeUnits);
    isCprClicked.value = true;
    // selectedMode.value = '';
    CprLock.I.lockFor(const Duration(seconds: 10));

    setState(() {});
  }

  String _getHeatImageAsset(int level) {
    switch (level) {
      case 1: return 'assets/btn_heat_level1.png';
      case 2: return 'assets/btn_heat_level2.png';
      case 3: return 'assets/btn_heat_level3.png';
      default: return 'assets/btn_heat_icon.png';
    }
  }

  String _getFanImageAsset(int level) {
    switch (level) {
      case 1: return 'assets/btn_fan_level1.png';
      case 2: return 'assets/btn_fan_level2.png';
      case 3: return 'assets/btn_fan_level3.png';
      default: return 'assets/btn_fan_icon.png';
    }
  }

  bool _isActive(BuildContext context, String routeName) {
    final current = ModalRoute.of(context)?.settings.name;
    return current == routeName || _activeRoute == routeName;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: SafeArea(
        child: Container(
          color: Colors.white,
          child: ValueListenableBuilder<bool>(
            valueListenable: CprLock.I.isLocked,
            builder: (context, locked, _) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final panelHeight = constraints.maxHeight;
                  final panelWidth = constraints.maxWidth;
                  final headerHeight = panelHeight * 0.10;
                  final spacing = panelWidth * 0.05;
                  final buttonSize = panelWidth * 0.42;
                  final smallIconSize = buttonSize / 2.5;
                  final cprWidth = buttonSize * 0.80;
                  final cprHeight = buttonSize / 2.5;
                  final isPressureActive = _isActive(context, AppRoutes.bodyPressure);
                  final isAlternatingActive = _isActive(context, AppRoutes.alternatingPressure);
                  final isMassageActive = _isActive(context, AppRoutes.massage);
                  final isCareActive = _isActive(context, AppRoutes.patientCare);
                  final padding = panelWidth * 0.06;

                  return Column(
                    children: [
                      SizedBox(
                        height: headerHeight,
                        child: PanelHeader(goto: _goto),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(padding),
                          child: Column(
                            children: [
                              SizedBox(height: spacing * 0.6),
                              Expanded(
                                child: _buildControlRow(
                                  leftAsset: locked ? 'assets/btn_pressure_disabled.png' : (isPressureActive ? 'assets/btn_pressure_focused.png' : 'assets/btn_pressure_icon.png'),
                                  rightAsset: locked ? 'assets/btn_alternating_disabled.png' : (isAlternatingActive ? 'assets/btn_alternating_focused.png' : 'assets/btn_alternating_icon.png'),
                                  buttonSize: buttonSize,
                                  spacing: spacing,
                                  leftOnPressed: locked ? null : () => _goto(context, AppRoutes.bodyPressure),
                                  rightOnPressed: locked ? null : () => _goto(context, AppRoutes.alternatingPressure),
                                ),
                              ),
                              SizedBox(height: spacing * 1.2),
                              Expanded(
                                child: _buildControlRow(
                                  leftAsset: locked ? 'assets/btn_massage_disabled.png' : (isMassageActive ? 'assets/btn_massage_focused.png' : 'assets/btn_massage_icon.png'),
                                  rightAsset: locked ? 'assets/btn_smart_care_disabled.png' : (isCareActive ? 'assets/btn_smart_care_focused.png' : 'assets/btn_smart_care_icon.png'),
                                  buttonSize: buttonSize,
                                  spacing: spacing,
                                  leftOnPressed: locked ? null : () => _goto(context, AppRoutes.massage),
                                  rightOnPressed: locked ? null : () => _goto(context, AppRoutes.patientCare),
                                ),
                              ),
                              SizedBox(height: spacing * 1.2),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: ValueListenableBuilder<bool>(
                                          valueListenable: CprLock.I.isLocked,
                                          builder: (context, locked, _) {
                                            return ValueListenableBuilder<bool>(
                                              valueListenable: isPauseFocused,
                                              builder: (_, pause, _) {
                                                return ValueListenableBuilder<bool>(
                                                  valueListenable: activeMode,
                                                  builder: (_, isStart, _) {
                                                    String asset;

                                                    if (locked) {
                                                      asset = 'assets/btn_pause_disabled.png'; 
                                                    } else if (isStart) {
                                                      asset = pause ? 'assets/btn_pause_focused.png' : 'assets/btn_pause_icon.png';
                                                    } else {
                                                      asset = pause ? 'assets/btn_pause_icon.png' : 'assets/btn_pause_focused.png';
                                                    }

                                                    return _imageControlButton(
                                                      assetPath: asset,
                                                      size: buttonSize,
                                                      onPressed: locked ? null : _action,
                                                    );
                                                  },
                                                );
                                              },
                                            );
                                          },
                                        )
                                      ),
                                    ),
                                    SizedBox(width: spacing),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: SizedBox(
                                          width: buttonSize,
                                          height: buttonSize,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  GestureDetector(
                                                    onTap: locked ? null : _heat,
                                                    child: ValueListenableBuilder<int>(
                                                      valueListenable: heatLevel,
                                                      builder: (_, value, _) {
                                                        return Image.asset(
                                                          _getHeatImageAsset(value),
                                                          width: smallIconSize,
                                                          height: smallIconSize,
                                                          fit: BoxFit.contain,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  SizedBox(width: buttonSize * 0.05),
                                                  GestureDetector(
                                                    onTap: locked ? null : _fan,
                                                    child: ValueListenableBuilder<int>(
                                                      valueListenable: fanLevel,
                                                      builder: (_, value, _) {
                                                        return Image.asset(
                                                          _getFanImageAsset(value),
                                                          width: smallIconSize,
                                                          height: smallIconSize,
                                                          fit: BoxFit.contain,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              GestureDetector(
                                                onTap: locked ? null : _cpr,
                                                child: ValueListenableBuilder<bool>(
                                                  valueListenable: isCprClicked,
                                                  builder: (_, clicked, _) {
                                                    return Image.asset(
                                                      clicked ? 'assets/btn_CPR_clicked.png' : 'assets/btn_CPR.png',
                                                      width: cprWidth,
                                                      height: cprHeight,
                                                      fit: BoxFit.contain,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildControlRow({
    required String leftAsset,
    required String rightAsset,
    required double buttonSize,
    required double spacing,
    required VoidCallback? leftOnPressed,
    required VoidCallback? rightOnPressed,
  }) {
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: _imageControlButton(
              assetPath: leftAsset,
              size: buttonSize,
              onPressed: leftOnPressed,
            ),
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: _imageControlButton(
              assetPath: rightAsset,
              size: buttonSize,
              onPressed: rightOnPressed,
            ),
          ),
        ),
      ],
    );
  }

  Widget _imageControlButton({
    required String assetPath,
    required double size,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: EdgeInsets.zero,
        fixedSize: Size(size, size),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
      child: Image.asset(assetPath, fit: BoxFit.contain),
    );
  }
}

class PanelHeader extends StatelessWidget {
  final void Function(BuildContext, String) goto;

  const PanelHeader({super.key, required this.goto});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final logoBase = (w * 0.36).clamp(48.0, 150.0).toDouble();
        final iconBase = (w * 0.11).clamp(24.0, 52.0).toDouble();
        double gap = (w * 0.08).clamp(12.0, 105.0).toDouble();

        const logoScale = 1.5;
        const iconScale = 1.3;
        double logoSize = logoBase * logoScale;
        double iconSize = iconBase * iconScale;

        final total = iconSize * 2 + logoSize + gap * 2;
        final s = total > w ? w / total : 1.0;
        logoSize *= s;
        iconSize *= s;
        gap *= s;

        Widget tappableImage({
          required String asset,
          required double size,
          required VoidCallback onTap,
        }) {
          return SizedBox(
            width: size,
            height: size,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(size * 0.2),
                child: Center(
                  child: Image.asset(asset, width: size, height: size, fit: BoxFit.contain),
                ),
              ),
            ),
          );
        }

        return Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              tappableImage(
                asset: 'assets/home-01.png',
                size: iconSize,
                onTap: () => goto(context, AppRoutes.home),
              ),
              SizedBox(width: gap),
              SizedBox(
                width: logoSize,
                height: logoSize,
                child: Center(
                  child: Image.asset('assets/BI.png', width: logoSize, height: logoSize, fit: BoxFit.contain),
                ),
              ),
              SizedBox(width: gap),
              tappableImage(
                asset: 'assets/settings-02.png',
                size: iconSize,
                onTap: () => goto(context, AppRoutes.setup),
              ),
            ],
          ),
        );
      },
    );
  }
}

void showCenterToast(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  final entry = OverlayEntry(
    builder: (context) => Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);
  Future.delayed(const Duration(seconds: 2), () => entry.remove());
}