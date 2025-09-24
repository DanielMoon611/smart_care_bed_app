import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_care_bed_app/value.dart';
import 'package:smart_care_bed_app/network/ble_service.dart';
import 'dart:math' as math;

class CprLock {
  CprLock._();
  static final CprLock I = CprLock._();

  final ValueNotifier<bool> isLocked = ValueNotifier<bool>(false);
  Timer? _timer;

  void lockFor(Duration d) {
    _timer?.cancel();
    isLocked.value = true;
    _timer = Timer(d, () {
      isLocked.value = false;
    });
  }
}

class BodyPressureDistributionPage extends StatefulWidget {
  const BodyPressureDistributionPage({super.key});

  @override
  State<BodyPressureDistributionPage> createState() => _BodyPressureDistributionPageState();
}

class _BodyPressureDistributionPageState extends State<BodyPressureDistributionPage> {
  final ValueNotifier<double> head           = ValueNotifier(5.0);
  final ValueNotifier<double> body1          = ValueNotifier(5.0);
  final ValueNotifier<double> body2          = ValueNotifier(5.0);
  final ValueNotifier<double> reg            = ValueNotifier(5.0);

  final ValueNotifier<String> selectedMode   = ValueNotifier('BPD');
  final ValueNotifier<bool> isSettingFocused = ValueNotifier(false);
  final ValueNotifier<bool> isInitFocused    = ValueNotifier(false);

  @override
  void dispose() {
    head.dispose();
    body1.dispose();
    body2.dispose();
    reg.dispose();
    isSettingFocused.dispose();
    isInitFocused.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final screenWidth  = c.maxWidth;
      final screenHeight = c.maxHeight;
      final titleAreaHeight    = screenHeight * 0.2;

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
                        '체압분산',
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: const [Shadow(blurRadius: 5, color: Colors.black, offset: Offset(1, 1))],
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.01),
                      Text(
                        'Body Pressure Distribution',
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
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 13.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                            SizedBox(
                                width: screenWidth * 0.12,
                                height: screenHeight * 0.77,
                                child: FittedBox(
                                  alignment: Alignment.centerRight,
                                  fit: BoxFit.fill,
                                  child: Image.asset(
                                    'assets/guide_bed_left.png',
                                    gaplessPlayback: true,
                                  ),
                                ),
                              ),
                              Image.asset(
                                'assets/bar_default_all_human.png',
                                fit: BoxFit.contain,
                                height: screenHeight * 0.8,
                                gaplessPlayback: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: Colors.black26,
                    ),
                    
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
                        child: Column(
                          children: [
                            const Expanded(flex: 2, child: SizedBox()),

                            Container(height: 1, color: Colors.black26),

                            Expanded(
                              flex: 4,
                              child: LayoutBuilder(
                                builder: (context, box) {
                                  final h   = box.maxHeight;
                                  final per = h / 4;
                                  final groupOuterW = (box.maxWidth * 0.95).toDouble();
                                  final groupInnerW = (box.maxWidth * 0.95).toDouble();

                                  final labelFontSize = ((screenWidth * 0.020).clamp(16.0, 28.0)).toDouble();
                                  final labelHeight   = labelFontSize * 1.3;

                                  Widget one({
                                    required String label,
                                    required ValueNotifier<double> v,
                                    required double sliderWidth,
                                  }) {
                                    return SizedBox(
                                      height: per,
                                      child: _sliderBlock(
                                        context,
                                        label: label,
                                        value: v,
                                        screenWidth: screenWidth,
                                        labelFontSize: labelFontSize,
                                        labelHeight: labelHeight,
                                        sliderWidth: sliderWidth,
                                      ),
                                    );
                                  }

                                  return Column(
                                    children: [
                                      one(label: '머리',     v: head,  sliderWidth: groupOuterW),
                                      one(label: '몸통(상)', v: body1, sliderWidth: groupInnerW),
                                      one(label: '몸통(하)', v: body2, sliderWidth: groupInnerW),
                                      one(label: '다리',     v: reg,   sliderWidth: groupOuterW),
                                    ],
                                  );
                                },
                              ),
                            ),

                            Container(height: 1, color: Colors.black26),

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
                                              Expanded(
                                                child: ValueListenableBuilder<bool>(
                                                  valueListenable: isSettingFocused,
                                                  builder: (context, focused, _) {
                                                    return GestureDetector(
                                                      behavior: HitTestBehavior.opaque,
                                                      onTap: () {
                                                        isSettingFocused.value = !focused;
                                                        debugPrint("SETTING pressed");
                                                      },
                                                      child: FittedBox(
                                                        fit: BoxFit.contain,
                                                        child: Image.asset(
                                                          focused ? 'assets/btn_setting_focused.png' : 'assets/btn_setting.png',
                                                          gaplessPlayback: true,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Expanded(
                                                child: ValueListenableBuilder<bool>(
                                                  valueListenable: isInitFocused,
                                                  builder: (context, focused, _) {
                                                    return GestureDetector(
                                                      behavior: HitTestBehavior.opaque,
                                                      onTap: () async {
                                                        if (BleService.I.firstConnectedId == null) {
                                                          showCenterToast(context, "침대를 연결해주세요");
                                                          return;
                                                        } else {
                                                          isInitFocused.value = !focused;
                                                          await BleService.I.sendToAllConnected('INIT'.codeUnits);
                                                          debugPrint("INIT pressed");
                                                        }
                                                        isCprClicked.value = true;
                                                        CprLock.I.lockFor(const Duration(seconds: 10));
                                                        debugPrint("CPR 실행 → 10초 락");
                                                      },
                                                      child: FittedBox(
                                                        fit: BoxFit.contain,
                                                        child: Image.asset(
                                                          focused ? 'assets/btn_init_focused.png' : 'assets/btn_init.png',
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

                                      const VerticalDivider(
                                        width: 1,
                                        thickness: 1,
                                        color: Colors.black26,
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
                                                      return GestureDetector(
                                                        onTap: () async {
                                                          if (BleService.I.firstConnectedId == null) {
                                                            showCenterToast(context, "침대를 연결해주세요");
                                                            return;
                                                          }
                                                          if (isStart) {
                                                            activeMode.value = false;
                                                            if (mode == '체압분산') {
                                                              final command = selectedMode.value;
                                                              debugPrint("$mode을 실행");
                                                              await BleService.I.sendToAllConnected(command.codeUnits);
                                                            } else if (mode != '체압분산' || mode == '') {
                                                              mode = '체압분산';
                                                              final command = selectedMode.value;
                                                              debugPrint("$mode을 실행");
                                                              await BleService.I.sendToAllConnected(command.codeUnits);
                                                            }
                                                          } else {
                                                            activeMode.value = true;
                                                            debugPrint("$mode을 종료");
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
                                                            isStart ? 'assets/btn_start.png' : 'assets/btn_stop.png',
                                                            fit: BoxFit.contain,
                                                            gaplessPlayback: true,
                                                          ),
                                                        ),
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
          ],
        ),
      );
    });
  }

  Widget _sliderBlock(
    BuildContext context, {
    required String label,
    required ValueNotifier<double> value,
    required double screenWidth,

    required double labelFontSize,
    required double labelHeight,
    required double sliderWidth,
  }) {
    return ValueListenableBuilder<double>(
      valueListenable: value,
      builder: (context, v, child) {
        final sliderValue = v.toInt().clamp(0, 10);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: labelHeight,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: labelFontSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: sliderWidth,
                  height: double.infinity,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragUpdate: (details) {
                      final dx = details.delta.dx;
                      value.value = (value.value + dx / 20).clamp(0, 10);
                    },
                    onTapDown: (details) {
                      final x = details.localPosition.dx.clamp(0.0, sliderWidth);
                      final newVal = (x / sliderWidth) * 10.0;
                      value.value = newVal.clamp(0, 10);
                    },
                    child: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Image.asset(
                        'assets/slider_${sliderValue.toString().padLeft(2, '0')}.png',
                        gaplessPlayback: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
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