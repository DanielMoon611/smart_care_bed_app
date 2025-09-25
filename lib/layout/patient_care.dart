import 'package:flutter/material.dart';
import 'package:smart_care_bed_app/value.dart';
import 'package:smart_care_bed_app/network/ble_service.dart';
import 'dart:math' as math;

class PatientCarePage extends StatefulWidget {
  const PatientCarePage({super.key});

  @override
  State<PatientCarePage> createState() => _PatientCarePage();
}

class _PatientCarePage extends State<PatientCarePage> {
  // final ValueNotifier<String> selectedMode = ValueNotifier('CARE1');
  final ValueNotifier<bool> isSettingFocused = ValueNotifier(false);
  final ValueNotifier<bool> isInitFocused = ValueNotifier(false);
  final ValueNotifier<String?> toggleSelection = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    selectedMode.value = 'CARE1';
  }

  @override
  void dispose() {
    // selectedMode.dispose();
    isSettingFocused.dispose();
    isInitFocused.dispose();
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
                            '환자케어',
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
                            'Patient Care',
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

                          const VerticalDivider(
                            width: 1,
                            thickness: 1,
                            color: Colors.black26
                          ),

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
                                              builder: (context, selected, _) {
                                                return Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    _tapImage(
                                                      asset: selected == 'CARE1' ? 'assets/btn_care1_focused.png' : 'assets/btn_care1.png',
                                                      size: size,
                                                      onTap: () {
                                                        if (isToggleFocused.value) {
                                                          debugPrint("⚠️ 이동 동작중 → CARE1 선택 차단");
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
                                                        selectedMode.value = 'CARE1';
                                                      },
                                                    ),
                                                    SizedBox(width: gap),
                                                    _tapImage(
                                                      asset: selected == 'CARE2' ? 'assets/btn_care2_focused.png' : 'assets/btn_care2.png',
                                                      size: size,
                                                      onTap: () {
                                                        if (isToggleFocused.value) {
                                                          debugPrint("⚠️ 이동 동작중 → CARE2 선택 차단");
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
                                                        selectedMode.value = 'CARE2';
                                                      },
                                                    ),
                                                    SizedBox(width: gap),
                                                    _tapImage(
                                                      asset: selected == 'CARE3' ? 'assets/btn_care3_focused.png' : 'assets/btn_care3.png',
                                                      size: size,
                                                      onTap: () {
                                                        if (!activeMode.value) {
                                                          final m = globalMessengerKey.currentState;
                                                          m?.hideCurrentSnackBar();
                                                          m?.showSnackBar(
                                                            const SnackBar(
                                                              content: Text("모드를 종료해주세요"),
                                                              duration: Duration(seconds: 2),
                                                              behavior: SnackBarBehavior.floating,
                                                              margin: EdgeInsets.fromLTRB(12, 0, 12, 12),
                                                            ),
                                                          );
                                                          return;
                                                        }
                                                        selectedMode.value = 'CARE3';
                                                      },
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

                                  Container(height: 1, color: Colors.black26),

                                  Expanded(
                                    flex: 4,
                                    child: SizedBox.shrink(),
                                  ),

                                  Container(height: 1, color: Colors.black26),

                                  ValueListenableBuilder<String>(
                                    valueListenable: selectedMode,
                                    builder: (context, selected, _) {
                                      if (selected == 'CARE1' || selected == 'CARE2') {
                                        return Expanded(
                                          flex: 4,
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: IntrinsicHeight(
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: SizedBox.shrink()
                                                  ),
                                                  const VerticalDivider(
                                                    width: 1,
                                                    thickness: 1,
                                                    color: Colors.black26
                                                  ),
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
                                                                valueListenable: activeMode,
                                                                builder: (context, isStart, _) {
                                                                  return ValueListenableBuilder<bool>(
                                                                    valueListenable: isPauseFocused,
                                                                    builder: (context, pause, __) {
                                                                      String asset;

                                                                      if (isStart) {
                                                                        asset = 'assets/btn_start.png';
                                                                      } else {
                                                                        asset = pause ? 'assets/btn_start.png' : 'assets/btn_stop.png';
                                                                      }

                                                                      return GestureDetector(
                                                                        onTap: () async {
                                                                          if (BleService.I.firstConnectedId == null) {
                                                                            showCenterToast(context, "침대를 연결해주세요");
                                                                            return;
                                                                          }

                                                                          if (isStart) {
                                                                            activeMode.value = false;
                                                                            isPauseFocused.value = false;
                                                                            mode = selected;
                                                                            await BleService.I.sendToAllConnected(selectedMode.value.codeUnits);
                                                                          } else {
                                                                            activeMode.value = true;
                                                                            isPauseFocused.value = false;
                                                                            if (mode == 'CARE1' || mode == 'CARE2') {
                                                                              await BleService.I.sendToAllConnected('INIT'.codeUnits);
                                                                            } else {
                                                                              await BleService.I.sendToAllConnected('STOP'.codeUnits);
                                                                            }
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
                                                                    }
                                                                  );
                                                                },
                                                              ),
                                                            ),

                                                            // Positioned(
                                                            //   right: 10,
                                                            //   bottom: 10,
                                                            //   child: ValueListenableBuilder<bool>(
                                                            //     valueListenable: activeMode,
                                                            //     builder: (context, isStart, _) {
                                                            //       return GestureDetector(
                                                            //         onTap: () async {
                                                            //           if (BleService.I.firstConnectedId == null) {
                                                            //             showCenterToast(context, "침대를 연결해주세요");
                                                            //             return;
                                                            //           }
                                                            //           if (isStart) {
                                                            //             activeMode.value = false;
                                                            //             mode = selected;
                                                            //             debugPrint("$mode 실행");
                                                            //             await BleService.I.sendToAllConnected(selected.codeUnits);
                                                            //           } else {
                                                            //             activeMode.value = true;
                                                            //             debugPrint("$mode 종료");
                                                            //             if (mode == 'CARE1' || mode == 'CARE2') {
                                                            //               await BleService.I.sendToAllConnected('INIT'.codeUnits);
                                                            //             } else {
                                                            //               await BleService.I.sendToAllConnected('STOP'.codeUnits);
                                                            //             }
                                                            //             mode = '';
                                                            //           }
                                                            //         },
                                                            //         child: SizedBox(
                                                            //           width: size,
                                                            //           height: size,
                                                            //           child: Image.asset(
                                                            //             isStart ? 'assets/btn_start.png' : 'assets/btn_stop.png',
                                                            //             fit: BoxFit.contain,
                                                            //             gaplessPlayback: true,
                                                            //           ),
                                                            //         ),
                                                            //       );
                                                            //     },
                                                            //   ),
                                                            // ),
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      } else {
                                        return Expanded(
                                          flex: 4,
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: IntrinsicHeight(
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: ValueListenableBuilder<String?>(
                                                      valueListenable: toggleSelection,
                                                      builder: (context, selected, _) {
                                                        final isFocused = selected == 'left';
                                                        isToggleFocused.value = (selected == 'left' || selected == 'right');
                                                        return GestureDetector(
                                                          behavior: HitTestBehavior.opaque,
                                                          onTap: () async {
                                                            if (BleService.I.firstConnectedId == null) {
                                                              showCenterToast(context, "침대를 연결해주세요");
                                                              return;
                                                            }
                                                            if (toggleSelection.value == 'right') {
                                                              final m = globalMessengerKey.currentState;
                                                              m?.hideCurrentSnackBar();
                                                              m?.showSnackBar(
                                                                const SnackBar(
                                                                  content: Text("오른쪽 이동을 종료해주세요(오른쪽 방향 버튼을 다시 눌러 정지)"),
                                                                  duration: Duration(seconds: 2),
                                                                  behavior: SnackBarBehavior.floating,
                                                                  margin: EdgeInsets.fromLTRB(12, 0, 12, 12),
                                                                ),
                                                              );
                                                              return;
                                                            }
                                                            if (selected == null) {
                                                              mode = '돌봄';
                                                              toggleSelection.value = 'left';
                                                              debugPrint("Left ON");
                                                              await BleService.I.sendToAllConnected("LEFT".codeUnits);
                                                            } else if (isFocused) {
                                                              toggleSelection.value = null;
                                                              debugPrint("Left OFF");
                                                              await BleService.I.sendToAllConnected("STOP".codeUnits);
                                                              mode = '';
                                                            }
                                                          },
                                                          child: FittedBox(
                                                            fit: BoxFit.contain,
                                                            child: Image.asset(
                                                              isFocused ? 'assets/btn_left_focused.png' : 'assets/btn_left.png',
                                                              gaplessPlayback: true,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),

                                                  const VerticalDivider(
                                                    width: 1,
                                                    thickness: 1,
                                                    color: Colors.black26
                                                  ),

                                                  Expanded(
                                                    flex: 1,
                                                    child: ValueListenableBuilder<String?>(
                                                      valueListenable: toggleSelection,
                                                      builder: (context, selected, _) {
                                                        final isFocused = selected == 'right';
                                                        isToggleFocused.value = (selected == 'left' || selected == 'right');
                                                        return GestureDetector(
                                                          behavior: HitTestBehavior.opaque,
                                                          onTap: () async {
                                                            if (BleService.I.firstConnectedId == null) {
                                                              showCenterToast(context, "침대를 연결해주세요");
                                                              return;
                                                            }
                                                            if (toggleSelection.value == 'left') {
                                                              final m = globalMessengerKey.currentState;
                                                              m?.hideCurrentSnackBar();
                                                              m?.showSnackBar(
                                                                const SnackBar(
                                                                  content: Text("왼쪽 이동을 종료해주세요(왼쪽 방향 버튼을 다시 눌러 정지)"),
                                                                  duration: Duration(seconds: 2),
                                                                  behavior: SnackBarBehavior.floating,
                                                                  margin: EdgeInsets.fromLTRB(12, 0, 12, 12),
                                                                ),
                                                              );
                                                              return;
                                                            }
                                                            if (selected == null) {
                                                              mode = '돌봄';
                                                              toggleSelection.value = 'right';
                                                              debugPrint("Right ON");
                                                              await BleService.I.sendToAllConnected("RIGHT".codeUnits);
                                                            } else if (isFocused) {
                                                              toggleSelection.value =null;
                                                              debugPrint("Right OFF");
                                                              await BleService.I.sendToAllConnected("STOP".codeUnits);
                                                              mode = '';
                                                            }
                                                          },
                                                          child: FittedBox(
                                                            fit: BoxFit.contain,
                                                            child: Image.asset(
                                                              isFocused ? 'assets/btn_right_focused.png' : 'assets/btn_right.png',
                                                              gaplessPlayback: true,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    },
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