import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_care_bed_app/value.dart';
import 'package:smart_care_bed_app/network/ble_service.dart';
import 'dart:math' as math;

class MassagePage extends StatefulWidget {
  const MassagePage({super.key});

  @override
  State<MassagePage> createState() => _MassagePage();
}

class _MassagePage extends State<MassagePage> {
  final ValueNotifier<String> strength       = ValueNotifier('LV1');
  final ValueNotifier<bool> isSettingFocused = ValueNotifier(false);
  final ValueNotifier<bool> isInitFocused    = ValueNotifier(false);
  final ValueNotifier<int> massageIndex = ValueNotifier<int>(0);

  late VoidCallback _cprListener;
  late final StreamSubscription<String> _bleRxSub;

  @override
  void initState() {
    super.initState();
    _bleRxSub = BleService.I.rxText$.listen((msg) {
      if (msg.trim() == 'MSGEND') {
        if (mounted) {
          setState(() {
            activeMode.value = true;
            isPauseFocused.value = false;
          });
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      selectedMode.value = "MSG1/LV1";
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
    isSettingFocused.dispose();
    isInitFocused.dispose();
    _bleRxSub.cancel();
    CprLock.I.isLocked.removeListener(_cprListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: globalMessengerKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(builder: (context, c) {
          final screenWidth  = c.maxWidth;
          final screenHeight = c.maxHeight;
          final titleAreaHeight = screenHeight * 0.2;

          final double titleFontSize    = ((screenWidth * 0.042).clamp(24.0, 60.0)).toDouble();
          final double subtitleFontSize = ((screenWidth * 0.030).clamp(18.0, 40.0)).toDouble();
          final double titleBgWidth  = screenWidth * 0.78;
          final double titleBgHeight = titleAreaHeight * 0.95;

          return Container(
            color: Colors.white,
            child: Column(
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
                            '마사지',
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: const [
                                Shadow(blurRadius: 5, color: Colors.black, offset: Offset(1, 1)),
                              ],
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.01),
                          Text(
                            'Massage',
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

                                        return Align(
                                          alignment: Alignment.center,
                                          child: SizedBox(
                                            height: h,
                                            width: w,
                                            child: ValueListenableBuilder<int>(
                                              valueListenable: massageIndex,
                                              builder: (context, index, _) {
                                                return Stack(
                                                  children: [
                                                    Center(
                                                      child: Image.asset(
                                                        'assets/massage${index + 1}.png',
                                                        height: h,
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),

                                                    Positioned.fill(
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            flex: 1,
                                                            child: GestureDetector(
                                                              behavior: HitTestBehavior.translucent,
                                                              onTap: () {
                                                                massageIndex.value = (massageIndex.value > 0) ? massageIndex.value - 1 : 5;
                                                                selectedMode.value = "MSG${massageIndex.value + 1}";
                                                              },
                                                            ),
                                                          ),

                                                          const Expanded(flex: 3, child: SizedBox()),

                                                          Expanded(
                                                            flex: 1,
                                                            child: GestureDetector(
                                                              behavior: HitTestBehavior.translucent,
                                                              onTap: () {
                                                                massageIndex.value = (massageIndex.value < 5) ? massageIndex.value + 1 : 0;
                                                                selectedMode.value = "MSG${massageIndex.value + 1}";
                                                              },
                                                            ),
                                                          ),
                                                        ],
                                                      ),
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

                                  Expanded(
                                    flex: 4,
                                    child: LayoutBuilder(
                                      builder: (context, box) {
                                        final double h   = box.maxHeight;
                                        final double w   = box.maxWidth;
                                        final double gap = (screenWidth * 0.01);
                                        final double size = math.min(h, (w - 2 * gap) / 3);
                                        return Align(
                                          alignment: Alignment.bottomCenter,
                                          child: SizedBox(
                                            height: h,
                                            width: w,
                                            child: ValueListenableBuilder<String>(
                                              valueListenable: strength,
                                              builder: (context, massageStrength, _) {
                                                return Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    _tapImage(
                                                      asset: massageStrength == 'LV1' ? 'assets/btn_massage_lower_focused.png' : 'assets/btn_massage_lower.png',
                                                      size: size,
                                                      onTap: () {strength.value = 'LV1';},
                                                    ),
                                                    SizedBox(width: gap),
                                                    _tapImage(
                                                      asset: massageStrength == 'LV2' ? 'assets/btn_massage_middle_focused.png' : 'assets/btn_massage_middle.png',
                                                      size: size,
                                                      onTap: () {strength.value = 'LV2';},
                                                    ),
                                                    SizedBox(width: gap),
                                                    _tapImage(
                                                      asset: massageStrength == 'LV3' ? 'assets/btn_massage_upper_focused.png' : 'assets/btn_massage_upper.png',
                                                      size: size,
                                                      onTap: () {strength.value = 'LV3';},
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

                                  Expanded(
                                    flex: 4,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: IntrinsicHeight(
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.stretch,
                                          children: [
                                            const Expanded(flex: 1, child: SizedBox.shrink()),
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
                                                                          mode = "마사지";
                                                                          selectedMode.value = "MSG${massageIndex.value + 1}/${strength.value}";
                                                                          if (isPauseFocused.value) {
                                                                            isPauseFocused.value = false;
                                                                          }
                                                                          await BleService.I.sendToCommand(selectedMode.value.codeUnits);
                                                                        } else {
                                                                          activeMode.value = true;
                                                                          isPauseFocused.value = false;
                                                                          await BleService.I.sendToCommand('STOP'.codeUnits);
                                                                          CprLock.I.lockFor(const Duration(seconds: 15));
                                                                          mode = '';
                                                                          selectedMode.value = '';
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
            ),
          );
        }),
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
        child: Image.asset(
          asset,
          gaplessPlayback: true,
        ),
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
