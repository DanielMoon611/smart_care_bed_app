import 'package:flutter/material.dart';
import 'package:smart_care_bed_app/value.dart';
import 'package:smart_care_bed_app/network/ble_service.dart';
import 'dart:math' as math;

class AlternatingPressurePage extends StatefulWidget {
  const AlternatingPressurePage({super.key});

  @override
  State<AlternatingPressurePage> createState() => _AlternatingPressurePageState();
}

class _AlternatingPressurePageState extends State<AlternatingPressurePage> {
  final ValueNotifier<double> head = ValueNotifier(5.0);
  final ValueNotifier<double> body1 = ValueNotifier(5.0);
  final ValueNotifier<double> body2 = ValueNotifier(5.0);
  final ValueNotifier<double> reg = ValueNotifier(5.0);

  final ValueNotifier<bool> isSettingFocused = ValueNotifier(false);
  final ValueNotifier<bool> isInitFocused = ValueNotifier(false);

  late VoidCallback _cprListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      selectedMode.value = "STD1";
    });

    _cprListener = () {
      if (CprLock.I.isLocked.value) {
        if (mounted) setState(() {});
      } else {
        isPauseFocused.value = false;
        activeMode.value = true;
        mode = '';
        if (mounted) setState(() {});
      }
    };
    CprLock.I.isLocked.addListener(_cprListener);
  }

  @override
  void dispose() {
    head.dispose();
    body1.dispose();
    body2.dispose();
    reg.dispose();
    isSettingFocused.dispose();
    isInitFocused.dispose();
    CprLock.I.isLocked.removeListener(_cprListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: globalMessengerKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (context, c) {
            final screenWidth = c.maxWidth;
            final screenHeight = c.maxHeight;
            final titleAreaHeight = screenHeight * 0.2;

            final double titleFontSize = ((screenWidth * 0.042).clamp(24.0, 60.0)).toDouble();
            final double subtitleFontSize = ((screenWidth * 0.030).clamp(18.0, 40.0)).toDouble();

            final double titleBgWidth = screenWidth * 0.78;
            final double titleBgHeight = titleAreaHeight * 0.95;

            return Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/Title_bg.png',
                        fit: BoxFit.contain,
                        width: titleBgWidth,
                        height: titleBgHeight,
                        gaplessPlayback: true,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '교대부양',
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: const [
                                Shadow(
                                  blurRadius: 5,
                                  color: Colors.black,
                                  offset: Offset(1, 1)
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.01),
                          Text(
                            'Alternating Pressure',
                            style: TextStyle(
                              fontSize: subtitleFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 9,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 13.0),
                                child: Image.asset(
                                  'assets/bar_default_all_human.png',
                                  fit: BoxFit.contain,
                                  height: screenHeight * 0.8,
                                  gaplessPlayback: true,
                                ),
                              ),
                            ),
                          ),

                          const VerticalDivider(width: 1, thickness: 1, color: Colors.white),

                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: LayoutBuilder(
                                      builder: (context, box) {
                                        final double h = box.maxHeight;
                                        final double w = box.maxWidth;
                                        final double gap = (screenWidth * 0.01);
                                        final double size = math.min(h, (w - 2 * gap) / 3);

                                        return Align(
                                          alignment: Alignment.bottomCenter,
                                          child: SizedBox(
                                            height: h,
                                            width: w,
                                            child: ValueListenableBuilder<String>(
                                              valueListenable: selectedMode,
                                              builder: (context, mode, _) {
                                                return Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    _tapImage(
                                                      asset: mode == 'STD1' ? 'assets/btn_std1_focused.png' : 'assets/btn_std1.png',
                                                      size: size,
                                                      onTap: () => selectedMode.value = 'STD1',
                                                    ),
                                                    SizedBox(width: gap),
                                                    _tapImage(
                                                      asset: mode == 'STD2' ? 'assets/btn_std2_focused.png' : 'assets/btn_std2.png',
                                                      size: size,
                                                      onTap: () => selectedMode.value = 'STD2',
                                                    ),
                                                    SizedBox(width: gap),
                                                    _tapImage(
                                                      asset: mode == 'STD3' ? 'assets/btn_std3_focused.png' : 'assets/btn_std3.png',
                                                      size: size,
                                                      onTap: () => selectedMode.value = 'STD3',
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                  Container(height: 1, color: Colors.white),
                                  Expanded(flex: 4, child: SizedBox.shrink()),
                                  Container(height: 1, color: Colors.white),

                                  Expanded(
                                    flex: 4,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: IntrinsicHeight(
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 6.0),
                                                child: Column(
                                                  children: [
                                                    Expanded(flex: 1, child: SizedBox.shrink()),
                                                    const SizedBox(height: 8),
                                                    Expanded(
                                                      flex: 1,
                                                      child: ValueListenableBuilder<bool>(
                                                        valueListenable: isSettingFocused,
                                                        builder: (context, focused, _) {
                                                          return ValueListenableBuilder<bool>(
                                                            valueListenable: activeMode,
                                                            builder: (context, isStart, _) {
                                                              final bool isStopMode = !isStart;
                                                              final String asset = isStopMode ? 'assets/btn_setting_disabled.png' : (focused ? 'assets/btn_setting_focused.png' : 'assets/btn_setting.png');

                                                              return GestureDetector(
                                                                onTap: () async {
                                                                  if (isStopMode) {
                                                                    ScaffoldMessenger.of(context)
                                                                      ..hideCurrentSnackBar()
                                                                      ..showSnackBar(
                                                                        const SnackBar(
                                                                          content: Text("모드를 종료해주세요", textAlign: TextAlign.center),
                                                                          duration: Duration(seconds: 2),
                                                                          behavior: SnackBarBehavior.floating,
                                                                          margin: EdgeInsets.fromLTRB(12, 0, 12, 12),
                                                                        ),
                                                                      );
                                                                    return;
                                                                  }

                                                                  isSettingFocused.value = !focused;
                                                                  if (!focused) {
                                                                    await showDialog(
                                                                      context: context,
                                                                      barrierDismissible: true,
                                                                      builder: (context) {
                                                                        return Dialog(
                                                                          backgroundColor: Colors.white,
                                                                          insetPadding: const EdgeInsets.all(20),
                                                                          shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(16),
                                                                          ),
                                                                          child: Stack(
                                                                            children: [
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(20.0),
                                                                                child: SizedBox(
                                                                                  width: 420,
                                                                                  height: 300,
                                                                                  child: Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                                    children: [
                                                                                      const SizedBox(height: 40),
                                                                                      const Expanded(
                                                                                        child: Center(
                                                                                          child: Text(
                                                                                            '설정 창입니다',
                                                                                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      const SizedBox(height: 20),
                                                                                      Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                                                        children: [
                                                                                          ElevatedButton(
                                                                                            onPressed: () {Navigator.of(context).pop();},
                                                                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                                                                            child: const Text('초기화', style: TextStyle(fontSize: 16)),
                                                                                          ),
                                                                                          const SizedBox(width: 12),
                                                                                          ElevatedButton(
                                                                                            onPressed: () {Navigator.of(context).pop();},
                                                                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                                                                            child: const Text('저장', style: TextStyle(fontSize: 16)),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Positioned(
                                                                                left: 10,
                                                                                top: 10,
                                                                                child: IconButton(
                                                                                  icon: const Icon(Icons.close, color: Colors.black87),
                                                                                  onPressed: () {Navigator.of(context).pop();},
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        );
                                                                      },
                                                                    );
                                                                    isSettingFocused.value = false;
                                                                  }
                                                                },
                                                                child: FittedBox(
                                                                  fit: BoxFit.contain,
                                                                  child: Image.asset(
                                                                    asset,
                                                                    gaplessPlayback: true,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),

                                            const VerticalDivider(width: 1, thickness: 1, color: Colors.white),

                                            Expanded(
                                              flex: 2,
                                              child: LayoutBuilder(
                                                builder: (context, box) {
                                                  final double h = box.maxHeight;
                                                  final double w = box.maxWidth;
                                                  final double size = math.min(w, h);

                                                  return Stack(
                                                    children: [
                                                      Positioned(
                                                        right: 10,
                                                        bottom: 10,
                                                        child: ValueListenableBuilder<bool>(
                                                          valueListenable: CprLock.I.isLocked,
                                                          builder: (context, locked, _) {
                                                            return ValueListenableBuilder<bool>(
                                                              valueListenable: activeMode,
                                                              builder: (context, isStart, _) {
                                                                return ValueListenableBuilder<bool>(
                                                                  valueListenable: isPauseFocused,
                                                                  builder: (context, pause, _) {
                                                                    String asset;
                                                                    if (locked) {
                                                                      asset = isStart ? 'assets/btn_start_disabled.png' : 'assets/btn_stop_disabled.png';
                                                                    } else if (isStart) {
                                                                      asset = 'assets/btn_start.png';
                                                                    } else {
                                                                      asset = pause ? 'assets/btn_start.png' : 'assets/btn_stop.png';
                                                                    }
                                                                    
                                                                    return GestureDetector(
                                                                      onTap: locked ? null : () async {
                                                                        if (BleService.I.firstConnectedId == null) {
                                                                          showCenterToast(context, "침대를 연결해주세요");
                                                                          return;
                                                                        }
                                                                        if (isStart || isPauseFocused.value) {
                                                                          activeMode.value = false;
                                                                          mode = "교대부양";
                                                                          final command = selectedMode.value;
                                                                          if (isPauseFocused.value) {
                                                                            isPauseFocused.value = false;
                                                                          }
                                                                          await BleService.I.sendToAllConnected(command.codeUnits);
                                                                        } else {
                                                                          activeMode.value = true;
                                                                          isPauseFocused.value = false;
                                                                          await BleService.I.sendToAllConnected('STOP'.codeUnits);
                                                                          CprLock.I.lockFor(const Duration(seconds: 15));
                                                                          mode = '';
                                                                        }
                                                                      },
                                                                      child: SizedBox(
                                                                        width: size,
                                                                        height: size,
                                                                        child: Image.asset(
                                                                          asset,
                                                                          fit: BoxFit.contain,
                                                                          gaplessPlayback: true,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Widget _tapImage({
  required String asset,
  required double size,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: SizedBox(
      width: size,
      height: size,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Image.asset(asset, gaplessPlayback: true),
      ),
    ),
  );
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
