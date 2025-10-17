// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:smart_care_bed_app/value.dart';
// import 'package:smart_care_bed_app/network/ble_service.dart';
// import 'dart:math' as math;

// class BodyPressureDistributionPage extends StatefulWidget {
//   const BodyPressureDistributionPage({super.key});

//   @override
//   State<BodyPressureDistributionPage> createState() => _BodyPressureDistributionPageState();
// }

// class _BodyPressureDistributionPageState extends State<BodyPressureDistributionPage> {
//   final ValueNotifier<double> head           = ValueNotifier(5.0);
//   final ValueNotifier<double> body1          = ValueNotifier(5.0);
//   final ValueNotifier<double> body2          = ValueNotifier(5.0);
//   final ValueNotifier<double> reg            = ValueNotifier(5.0);

//   // final ValueNotifier<String> selectedMode   = ValueNotifier('BPD');
//   final ValueNotifier<bool> isSettingFocused = ValueNotifier(false);
//   final ValueNotifier<bool> isInitFocused    = ValueNotifier(false);

//   late VoidCallback _cprListener;

//   @override
//   void initState() {
//     super.initState();
//     // selectedMode.value = 'BPD';
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       selectedMode.value = "BPD";
//     });
//     _cprListener = () {
//       if (CprLock.I.isLocked.value) {
//         if (mounted) setState(() {});
//       } else {
//         isPauseFocused.value = false;
//         activeMode.value = true;
//         mode = '';
//         if (mounted) setState(() {});
//       }
//     };

//     CprLock.I.isLocked.addListener(_cprListener);
//   }

//   @override
//   void dispose() {
//     head.dispose();
//     body1.dispose();
//     body2.dispose();
//     reg.dispose();
//     isSettingFocused.dispose();
//     isInitFocused.dispose();
//     CprLock.I.isLocked.removeListener(_cprListener);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(builder: (context, c) {
//       final screenWidth  = c.maxWidth;
//       final screenHeight = c.maxHeight;
//       final titleAreaHeight    = screenHeight * 0.2;

//       final double titleFontSize    = ((screenWidth * 0.042).clamp(24.0, 60.0)).toDouble();
//       final double subtitleFontSize = ((screenWidth * 0.030).clamp(18.0, 40.0)).toDouble();

//       final double titleBgWidth  = screenWidth * 0.78;
//       final double titleBgHeight = titleAreaHeight * 0.95;

//       return Container(
//         color: Colors.white,
//         child: Column(
//           children: [
//             Expanded(
//               flex: 1,
//               child: Stack(
//                 alignment: Alignment.center,
//                 children: [
//                   Image.asset(
//                     'assets/Title_bg.png',
//                     fit: BoxFit.contain,
//                     width: titleBgWidth,
//                     height: titleBgHeight,
//                     gaplessPlayback: true,
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         '체압분산',
//                         style: TextStyle(
//                           fontSize: titleFontSize,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                           shadows: const [Shadow(blurRadius: 5, color: Colors.black, offset: Offset(1, 1))],
//                         ),
//                       ),
//                       SizedBox(width: screenWidth * 0.01),
//                       Text(
//                         'Body Pressure Distribution',
//                         style: TextStyle(
//                           fontSize: subtitleFontSize,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.green,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               flex: 9,
//               child: Padding(
//                 padding: const EdgeInsets.only(top: 10.0),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       flex: 1,
//                       child: Align(
//                         alignment: Alignment.centerRight,
//                         child: Padding(
//                           padding: const EdgeInsets.only(right: 13.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               // SizedBox(
//                               //   width: screenWidth * 0.12,
//                               //   height: screenHeight * 0.77,
//                               //   child: FittedBox(
//                               //     alignment: Alignment.centerRight,
//                               //     fit: BoxFit.fill,
//                               //     child: Image.asset(
//                               //       'assets/guide_bed_left.png',
//                               //       gaplessPlayback: true,
//                               //     ),
//                               //   ),
//                               // ),
//                               Image.asset(
//                                 'assets/bar_default_all_human.png',
//                                 fit: BoxFit.contain,
//                                 height: screenHeight * 0.8,
//                                 gaplessPlayback: true,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),

//                     const VerticalDivider(
//                       width: 1,
//                       thickness: 1,
//                       color: Colors.black26,
//                     ),
                    
//                     Expanded(
//                       flex: 1,
//                       child: Padding(
//                         padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
//                         child: Column(
//                           children: [
//                             const Expanded(flex: 2, child: SizedBox()),

//                             Container(height: 1, color: Colors.black26),

//                             // Expanded(
//                             //   flex: 4,
//                             //   child: LayoutBuilder(
//                             //     builder: (context, box) {
//                             //       final h   = box.maxHeight;
//                             //       final per = h / 4;
//                             //       final groupOuterW = (box.maxWidth * 0.95).toDouble();
//                             //       final groupInnerW = (box.maxWidth * 0.95).toDouble();

//                             //       final labelFontSize = ((screenWidth * 0.020).clamp(16.0, 28.0)).toDouble();
//                             //       final labelHeight   = labelFontSize * 1.3;

//                             //       Widget one({
//                             //         required String label,
//                             //         required ValueNotifier<double> v,
//                             //         required double sliderWidth,
//                             //       }) {
//                             //         return SizedBox(
//                             //           height: per,
//                             //           child: _sliderBlock(
//                             //             context,
//                             //             label: label,
//                             //             value: v,
//                             //             screenWidth: screenWidth,
//                             //             labelFontSize: labelFontSize,
//                             //             labelHeight: labelHeight,
//                             //             sliderWidth: sliderWidth,
//                             //           ),
//                             //         );
//                             //       }

//                             //       return Column(
//                             //         children: [
//                             //           one(label: '머리',     v: head,  sliderWidth: groupOuterW),
//                             //           one(label: '몸통(상)', v: body1, sliderWidth: groupInnerW),
//                             //           one(label: '몸통(하)', v: body2, sliderWidth: groupInnerW),
//                             //           one(label: '다리',     v: reg,   sliderWidth: groupOuterW),
//                             //         ],
//                             //       );
//                             //     },
//                             //   ),
//                             // ),

//                             Expanded(
//                               flex: 4,
//                               child: SizedBox.shrink(),
//                             ),

//                             Container(height: 1, color: Colors.black26),

//                             Expanded(
//                               flex: 4,
//                               child: Padding(
//                                 padding: const EdgeInsets.only(top: 8.0),
//                                 child: IntrinsicHeight(
//                                   child: Row(
//                                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                                     children: [
//                                       Expanded(
//                                         flex: 1,
//                                         child: Padding(
//                                           padding: const EdgeInsets.symmetric(vertical: 6.0),
//                                           child: Column(
//                                             children: [
//                                               Expanded(
//                                                 flex: 1,
//                                                 child: SizedBox.shrink(),
//                                               ),
//                                               const SizedBox(height: 8),
//                                               Expanded(
//                                                 flex: 1,
//                                                 child: ValueListenableBuilder<bool>(
//                                                   valueListenable: isSettingFocused,
//                                                   builder: (context, focused, _) {
//                                                     return ValueListenableBuilder<bool>(
//                                                       valueListenable: activeMode, // START/STOP 상태 감시
//                                                       builder: (context, isStart, _) {
//                                                         // ⚙️ activeMode.value == true  → START 상태 (btn_start.png)
//                                                         // ⚙️ activeMode.value == false → STOP 상태 (btn_stop.png)

//                                                         final bool isStopMode = !isStart; // STOP 모드 판별

//                                                         // ✅ 이미지 선택
//                                                         final String asset;
//                                                         if (isStopMode) {
//                                                           asset = 'assets/btn_setting_disabled.png';
//                                                         } else {
//                                                           asset = focused
//                                                               ? 'assets/btn_setting_focused.png'
//                                                               : 'assets/btn_setting.png';
//                                                         }

//                                                         return GestureDetector(
//                                                           behavior: HitTestBehavior.opaque,
//                                                           onTap: () async {
//                                                             // ✅ STOP 상태에서는 버튼 비활성화 (눌리지 않음)
//                                                             if (isStopMode) {
//                                                               debugPrint("STOP 상태 - 설정 버튼 비활성화 중");
//                                                               return;
//                                                             }

//                                                             // ✅ START 상태에서는 기존 로직 유지
//                                                             isSettingFocused.value = !focused;
//                                                             debugPrint("SETTING pressed");

//                                                             if (!focused) {
//                                                               // ✅ 설정창 열기
//                                                               await showDialog(
//                                                                 context: context,
//                                                                 barrierDismissible: true,
//                                                                 builder: (context) {
//                                                                   return Dialog(
//                                                                     backgroundColor: Colors.white,
//                                                                     insetPadding: const EdgeInsets.all(20),
//                                                                     shape: RoundedRectangleBorder(
//                                                                       borderRadius: BorderRadius.circular(16),
//                                                                     ),
//                                                                     child: Stack(
//                                                                       children: [
//                                                                         Padding(
//                                                                           padding: const EdgeInsets.all(20.0),
//                                                                           child: SizedBox(
//                                                                             width: 420,
//                                                                             height: 300,
//                                                                             child: Column(
//                                                                               crossAxisAlignment: CrossAxisAlignment.stretch,
//                                                                               children: [
//                                                                                 const SizedBox(height: 40),
//                                                                                 const Expanded(
//                                                                                   child: Center(
//                                                                                     child: Text(
//                                                                                       '설정 창입니다',
//                                                                                       style: TextStyle(
//                                                                                         fontSize: 20,
//                                                                                         fontWeight: FontWeight.bold,
//                                                                                         color: Colors.black87,
//                                                                                       ),
//                                                                                     ),
//                                                                                   ),
//                                                                                 ),
//                                                                                 const SizedBox(height: 20),
//                                                                                 Row(
//                                                                                   mainAxisAlignment: MainAxisAlignment.end,
//                                                                                   children: [
//                                                                                     ElevatedButton(
//                                                                                       onPressed: () {
//                                                                                         debugPrint("초기화 버튼 클릭됨");
//                                                                                         Navigator.of(context).pop();
//                                                                                       },
//                                                                                       style: ElevatedButton.styleFrom(
//                                                                                         backgroundColor: Colors.green,
//                                                                                         foregroundColor: Colors.white,
//                                                                                         padding: const EdgeInsets.symmetric(
//                                                                                           horizontal: 20,
//                                                                                           vertical: 12,
//                                                                                         ),
//                                                                                         shape: RoundedRectangleBorder(
//                                                                                           borderRadius: BorderRadius.circular(8),
//                                                                                         ),
//                                                                                       ),
//                                                                                       child: const Text('초기화',
//                                                                                           style: TextStyle(fontSize: 16)),
//                                                                                     ),
//                                                                                     const SizedBox(width: 12),
//                                                                                     ElevatedButton(
//                                                                                       onPressed: () {
//                                                                                         debugPrint("저장 버튼 클릭됨");
//                                                                                         Navigator.of(context).pop();
//                                                                                       },
//                                                                                       style: ElevatedButton.styleFrom(
//                                                                                         backgroundColor: Colors.blue,
//                                                                                         foregroundColor: Colors.white,
//                                                                                         padding: const EdgeInsets.symmetric(
//                                                                                           horizontal: 20,
//                                                                                           vertical: 12,
//                                                                                         ),
//                                                                                         shape: RoundedRectangleBorder(
//                                                                                           borderRadius: BorderRadius.circular(8),
//                                                                                         ),
//                                                                                       ),
//                                                                                       child: const Text('저장',
//                                                                                           style: TextStyle(fontSize: 16)),
//                                                                                     ),
//                                                                                   ],
//                                                                                 ),
//                                                                               ],
//                                                                             ),
//                                                                           ),
//                                                                         ),
//                                                                         // ❌ 닫기(X) 버튼
//                                                                         Positioned(
//                                                                           left: 10,
//                                                                           top: 10,
//                                                                           child: IconButton(
//                                                                             icon: const Icon(Icons.close, color: Colors.black87),
//                                                                             onPressed: () {
//                                                                               Navigator.of(context).pop();
//                                                                             },
//                                                                           ),
//                                                                         ),
//                                                                       ],
//                                                                     ),
//                                                                   );
//                                                                 },
//                                                               );

//                                                               // ✅ 다이얼로그가 닫힌 뒤 (X 버튼, 저장/초기화, 바깥 클릭 등)
//                                                               isSettingFocused.value = false;
//                                                             }
//                                                           },
//                                                           child: FittedBox(
//                                                             fit: BoxFit.contain,
//                                                             child: Image.asset(
//                                                               asset,
//                                                               gaplessPlayback: true,
//                                                             ),
//                                                           ),
//                                                         );
//                                                       },
//                                                     );

//                                                     // return GestureDetector(
//                                                     //   behavior: HitTestBehavior.opaque,
//                                                     //   onTap: () async {
//                                                     //     isSettingFocused.value = !focused;
//                                                     //     debugPrint("SETTING pressed");

//                                                     //     if (!focused) {
//                                                     //       // ✅ 설정창 열기
//                                                     //       await showDialog(
//                                                     //         context: context,
//                                                     //         barrierDismissible: true, // 바깥 터치로 닫기 가능
//                                                     //         builder: (context) {
//                                                     //           return Dialog(
//                                                     //             backgroundColor: Colors.white,
//                                                     //             insetPadding: const EdgeInsets.all(20),
//                                                     //             shape: RoundedRectangleBorder(
//                                                     //               borderRadius: BorderRadius.circular(16),
//                                                     //             ),
//                                                     //             child: Stack(
//                                                     //               children: [
//                                                     //                 Padding(
//                                                     //                   padding: const EdgeInsets.all(20.0),
//                                                     //                   child: SizedBox(
//                                                     //                     width: 420,
//                                                     //                     height: 300,
//                                                     //                     child: Column(
//                                                     //                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                                                     //                       children: [
//                                                     //                         const SizedBox(height: 40),

//                                                     //                         const Expanded(
//                                                     //                           child: Center(
//                                                     //                             child: Text(
//                                                     //                               '설정 창입니다',
//                                                     //                               style: TextStyle(
//                                                     //                                 fontSize: 20,
//                                                     //                                 fontWeight: FontWeight.bold,
//                                                     //                                 color: Colors.black87,
//                                                     //                               ),
//                                                     //                             ),
//                                                     //                           ),
//                                                     //                         ),

//                                                     //                         const SizedBox(height: 20),

//                                                     //                         Row(
//                                                     //                           mainAxisAlignment: MainAxisAlignment.end,
//                                                     //                           children: [
//                                                     //                             ElevatedButton(
//                                                     //                               onPressed: () {
//                                                     //                                 debugPrint("초기화 버튼 클릭됨");
//                                                     //                                 Navigator.of(context).pop();
//                                                     //                               },
//                                                     //                               style: ElevatedButton.styleFrom(
//                                                     //                                 backgroundColor: Colors.green,
//                                                     //                                 foregroundColor: Colors.white,
//                                                     //                                 padding: const EdgeInsets.symmetric(
//                                                     //                                   horizontal: 20,
//                                                     //                                   vertical: 12,
//                                                     //                                 ),
//                                                     //                                 shape: RoundedRectangleBorder(
//                                                     //                                   borderRadius: BorderRadius.circular(8),
//                                                     //                                 ),
//                                                     //                               ),
//                                                     //                               child: const Text('초기화', style: TextStyle(fontSize: 16)),
//                                                     //                             ),
//                                                     //                             const SizedBox(width: 12),
//                                                     //                             ElevatedButton(
//                                                     //                               onPressed: () {
//                                                     //                                 debugPrint("저장 버튼 클릭됨");
//                                                     //                                 Navigator.of(context).pop();
//                                                     //                               },
//                                                     //                               style: ElevatedButton.styleFrom(
//                                                     //                                 backgroundColor: Colors.blue,
//                                                     //                                 foregroundColor: Colors.white,
//                                                     //                                 padding: const EdgeInsets.symmetric(
//                                                     //                                   horizontal: 20,
//                                                     //                                   vertical: 12,
//                                                     //                                 ),
//                                                     //                                 shape: RoundedRectangleBorder(
//                                                     //                                   borderRadius: BorderRadius.circular(8),
//                                                     //                                 ),
//                                                     //                               ),
//                                                     //                               child: const Text('저장', style: TextStyle(fontSize: 16)),
//                                                     //                             ),
//                                                     //                           ],
//                                                     //                         ),
//                                                     //                       ],
//                                                     //                     ),
//                                                     //                   ),
//                                                     //                 ),

//                                                     //                 // ❌ 닫기(X) 버튼
//                                                     //                 Positioned(
//                                                     //                   left: 10,
//                                                     //                   top: 10,
//                                                     //                   child: IconButton(
//                                                     //                     icon: const Icon(Icons.close, color: Colors.black87),
//                                                     //                     onPressed: () {
//                                                     //                       Navigator.of(context).pop();
//                                                     //                     },
//                                                     //                   ),
//                                                     //                 ),
//                                                     //               ],
//                                                     //             ),
//                                                     //           );
//                                                     //         },
//                                                     //       );

//                                                     //       // ✅ 다이얼로그가 닫힌 뒤 (X 버튼, 저장/초기화, 바깥 클릭 등)
//                                                     //       isSettingFocused.value = false;
//                                                     //     }
//                                                     //   },
//                                                     //   child: FittedBox(
//                                                     //     fit: BoxFit.contain,
//                                                     //     child: Image.asset(
//                                                     //       focused ? 'assets/btn_setting_focused.png' : 'assets/btn_setting.png',
//                                                     //       gaplessPlayback: true,
//                                                     //     ),
//                                                     //   ),
//                                                     // );
//                                                   },
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),

//                                       const VerticalDivider(
//                                         width: 1,
//                                         thickness: 1,
//                                         color: Colors.black26,
//                                       ),

//                                       Expanded(
//                                         flex: 2,
//                                         child: LayoutBuilder(
//                                           builder: (context, box) {
//                                             final double h = box.maxHeight;
//                                             final double w = box.maxWidth;
//                                             final double size = math.min(w, h);

//                                             return Stack(
//                                               children: [
//                                                 Positioned(
//                                                   right: 10,
//                                                   bottom: 10,
//                                                   child: ValueListenableBuilder<bool>(
//                                                     valueListenable: CprLock.I.isLocked,
//                                                     builder: (context, locked, _) {
//                                                       return ValueListenableBuilder<bool>(
//                                                         valueListenable: activeMode,
//                                                         builder: (context, isStart, _) {
//                                                           return ValueListenableBuilder<bool>(
//                                                             valueListenable: isPauseFocused,
//                                                             builder: (context, pause, _) {
//                                                               String asset;

//                                                               if (locked) {
//                                                                 // CPR 실행 중 → 현재 상태에 맞는 disabled 아이콘
//                                                                 if (isStart) {
//                                                                   asset = 'assets/btn_start_disabled.png';
//                                                                 } else {
//                                                                   asset = 'assets/btn_stop_disabled.png';
//                                                                 }
//                                                               } else if (isStart) {
//                                                                 asset = 'assets/btn_start.png';
//                                                               } else {
//                                                                 asset = pause ? 'assets/btn_start.png' : 'assets/btn_stop.png';
//                                                               }

//                                                               return GestureDetector(
//                                                                 onTap: locked
//                                                                     ? null // ✅ CPR 실행 중 → START 버튼 아예 눌리지 않음
//                                                                     : () async {
//                                                                         if (BleService.I.firstConnectedId == null) {
//                                                                           showCenterToast(context, "침대를 연결해주세요");
//                                                                           return;
//                                                                         }

//                                                                         if (isStart || isPauseFocused.value) {
//                                                                           activeMode.value = false;
//                                                                           // isPauseFocused.value = false;
//                                                                           mode = "체압분산"; // 페이지에 맞게 모드명 수정
//                                                                           selectedMode.value = "BPD";

//                                                                           // ✅ PAUSE 상태였다면 해제하면서 START 실행
//                                                                           if (isPauseFocused.value) {
//                                                                             isPauseFocused.value = false;
//                                                                           }
                                                                          
//                                                                           await BleService.I.sendToAllConnected(selectedMode.value.codeUnits);
//                                                                         } else {
//                                                                           activeMode.value = true;
//                                                                           isPauseFocused.value = false;
//                                                                           await BleService.I.sendToAllConnected('STOP'.codeUnits);
//                                                                           mode = '';
//                                                                         }
//                                                                       },
//                                                                 child: SizedBox(
//                                                                   width: size,
//                                                                   height: size,
//                                                                   child: Image.asset(
//                                                                     asset,
//                                                                     fit: BoxFit.contain,
//                                                                     gaplessPlayback: true,
//                                                                   ),
//                                                                 ),
//                                                               );
//                                                             },
//                                                           );
//                                                         },
//                                                       );
//                                                     },
//                                                   )
//                                                 ),
//                                                 // Positioned(
//                                                 //   right: 10,
//                                                 //   bottom: 10,
//                                                 //   child: ValueListenableBuilder<bool>(
//                                                 //     valueListenable: activeMode,
//                                                 //     builder: (context, isStart, _) {
//                                                 //       // String asset;

//                                                 //       // // 🔹 패널 상태와 연동
//                                                 //       // if (pause) {
//                                                 //       //   // panel이 pause 상태 → STOP 버튼 보여줌
//                                                 //       //   asset = 'assets/btn_stop.png';
//                                                 //       // } else {
//                                                 //       //   // panel이 pause 아님 → START 버튼 보여줌
//                                                 //       //   asset = 'assets/btn_start.png';
//                                                 //       // }

//                                                 //       return GestureDetector(
//                                                 //         onTap: () async {
//                                                 //           if (BleService.I.firstConnectedId == null) {
//                                                 //             showCenterToast(context, "침대를 연결해주세요");
//                                                 //             return;
//                                                 //           }
//                                                 //           if (isStart) {
//                                                 //             activeMode.value = false;
//                                                 //             if (mode == '체압분산') {
//                                                 //               final command = selectedMode.value;
//                                                 //               debugPrint("$mode을 실행");
//                                                 //               await BleService.I.sendToAllConnected(command.codeUnits);
//                                                 //             } else if (mode != '체압분산' || mode == '') {
//                                                 //               mode = '체압분산';
//                                                 //               final command = selectedMode.value;
//                                                 //               debugPrint("$mode을 실행");
//                                                 //               await BleService.I.sendToAllConnected(command.codeUnits);
//                                                 //             }
//                                                 //           } else {
//                                                 //             activeMode.value = true;
//                                                 //             debugPrint("$mode을 종료");
//                                                 //             if (mode == 'CARE1' || mode == 'CARE2') {
//                                                 //               await BleService.I.sendToAllConnected('INIT'.codeUnits);
//                                                 //             } else {
//                                                 //               await BleService.I.sendToAllConnected('STOP'.codeUnits);
//                                                 //             }
//                                                 //             mode = '';
//                                                 //           }
//                                                 //         },
//                                                 //         child: SizedBox(
//                                                 //           width: size,
//                                                 //           height: size,
//                                                 //           child: Image.asset(
//                                                 //             isStart ? 'assets/btn_start.png' : 'assets/btn_stop.png',
//                                                 //             fit: BoxFit.contain,
//                                                 //             gaplessPlayback: true,
//                                                 //           ),
//                                                 //         ),
//                                                 //       );
//                                                 //     },
//                                                 //   ),
//                                                 // ),
//                                               ],
//                                             );
//                                           },
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     });
//   }

//   // Widget _sliderBlock(
//   //   BuildContext context, {
//   //   required String label,
//   //   required ValueNotifier<double> value,
//   //   required double screenWidth,

//   //   required double labelFontSize,
//   //   required double labelHeight,
//   //   required double sliderWidth,
//   // }) {
//   //   return ValueListenableBuilder<double>(
//   //     valueListenable: value,
//   //     builder: (context, v, child) {
//   //       final sliderValue = v.toInt().clamp(0, 10);
//   //       return Column(
//   //         crossAxisAlignment: CrossAxisAlignment.start,
//   //         children: [
//   //           SizedBox(
//   //             height: labelHeight,
//   //             child: Padding(
//   //               padding: const EdgeInsets.only(left: 8.0),
//   //               child: Align(
//   //                 alignment: Alignment.centerLeft,
//   //                 child: Text(
//   //                   label,
//   //                   maxLines: 1,
//   //                   overflow: TextOverflow.ellipsis,
//   //                   style: TextStyle(
//   //                     fontSize: labelFontSize,
//   //                     fontWeight: FontWeight.w700,
//   //                   ),
//   //                 ),
//   //               ),
//   //             ),
//   //           ),
//   //           Expanded(
//   //             child: Center(
//   //               child: SizedBox(
//   //                 width: sliderWidth,
//   //                 height: double.infinity,
//   //                 child: GestureDetector(
//   //                   behavior: HitTestBehavior.opaque,
//   //                   onHorizontalDragUpdate: (details) {
//   //                     final dx = details.delta.dx;
//   //                     value.value = (value.value + dx / 20).clamp(0, 10);
//   //                   },
//   //                   onTapDown: (details) {
//   //                     final x = details.localPosition.dx.clamp(0.0, sliderWidth);
//   //                     final newVal = (x / sliderWidth) * 10.0;
//   //                     value.value = newVal.clamp(0, 10);
//   //                   },
//   //                   child: FittedBox(
//   //                     fit: BoxFit.fitWidth,
//   //                     child: Image.asset(
//   //                       'assets/slider_${sliderValue.toString().padLeft(2, '0')}.png',
//   //                       gaplessPlayback: true,
//   //                     ),
//   //                   ),
//   //                 ),
//   //               ),
//   //             ),
//   //           ),
//   //         ],
//   //       );
//   //     },
//   //   );
//   // }
// }

// void showCenterToast(BuildContext context, String message) {
//   final overlay = Overlay.of(context);
//   final entry = OverlayEntry(
//     builder: (context) => Center(
//       child: Material(
//         color: Colors.transparent,
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//           decoration: BoxDecoration(
//             color: Colors.black87,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Text(
//             message,
//             style: const TextStyle(color: Colors.white, fontSize: 16),
//           ),
//         ),
//       ),
//     ),
//   );

//   overlay.insert(entry);
//   Future.delayed(const Duration(seconds: 2), () => entry.remove());
// }






import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_care_bed_app/value.dart';
import 'package:smart_care_bed_app/network/ble_service.dart';
import 'dart:math' as math;

class BodyPressureDistributionPage extends StatefulWidget {
  const BodyPressureDistributionPage({super.key});

  @override
  State<BodyPressureDistributionPage> createState() =>
      _BodyPressureDistributionPageState();
}

class _BodyPressureDistributionPageState
    extends State<BodyPressureDistributionPage> {
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
      selectedMode.value = "BPD";
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
    return ScaffoldMessenger( // ✅ SnackBar를 전체 페이지 기준으로 띄우기
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(builder: (context, c) {
          final screenWidth = c.maxWidth;
          final screenHeight = c.maxHeight;
          final titleAreaHeight = screenHeight * 0.2;

          final double titleFontSize =
              ((screenWidth * 0.042).clamp(24.0, 60.0)).toDouble();
          final double subtitleFontSize =
              ((screenWidth * 0.030).clamp(18.0, 40.0)).toDouble();

          final double titleBgWidth = screenWidth * 0.78;
          final double titleBgHeight = titleAreaHeight * 0.95;

          return Column(
            children: [
              // 상단 타이틀
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
                            shadows: const [
                              Shadow(
                                  blurRadius: 5,
                                  color: Colors.black,
                                  offset: Offset(1, 1)),
                            ],
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

              // 본문
              Expanded(
                flex: 9,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Row(
                    children: [
                      // 왼쪽
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
                          width: 1, thickness: 1, color: Colors.black26),

                      // 오른쪽
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.015),
                          child: Column(
                            children: [
                              const Expanded(flex: 2, child: SizedBox()),

                              Container(height: 1, color: Colors.black26),
                              Expanded(flex: 4, child: SizedBox.shrink()),
                              Container(height: 1, color: Colors.black26),

                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // ⚙ 설정 버튼
                                        Expanded(
                                          flex: 1,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6.0),
                                            child: Column(
                                              children: [
                                                Expanded(
                                                    flex: 1,
                                                    child: SizedBox.shrink()),
                                                const SizedBox(height: 8),
                                                Expanded(
                                                  flex: 1,
                                                  child:
                                                      ValueListenableBuilder<
                                                          bool>(
                                                    valueListenable:
                                                        isSettingFocused,
                                                    builder:
                                                        (context, focused, _) {
                                                      return ValueListenableBuilder<
                                                          bool>(
                                                        valueListenable:
                                                            activeMode,
                                                        builder: (context,
                                                            isStart, _) {
                                                          final bool
                                                              isStopMode =
                                                              !isStart;
                                                          final String asset =
                                                              isStopMode
                                                                  ? 'assets/btn_setting_disabled.png'
                                                                  : (focused
                                                                      ? 'assets/btn_setting_focused.png'
                                                                      : 'assets/btn_setting.png');

                                                          return GestureDetector(
                                                            onTap: () async {
                                                              if (isStopMode) {
                                                                // ✅ SnackBar를 “본문 전체 하단” 기준으로 띄움
                                                                ScaffoldMessenger
                                                                        .of(
                                                                            context)
                                                                    ..hideCurrentSnackBar()
                                                                    ..showSnackBar(
                                                                      const SnackBar(
                                                                        content:
                                                                            Text(
                                                                          "모드를 종료해주세요",
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                        ),
                                                                        duration:
                                                                            Duration(seconds: 2),
                                                                        behavior:
                                                                                SnackBarBehavior.floating,
                                                                        margin: EdgeInsets.fromLTRB(12, 0, 12, 12),
                                                                      ),
                                                                    );
                                                                return;
                                                              }

                                                              isSettingFocused
                                                                      .value =
                                                                  !focused;
                                                              if (!focused) {
                                                                await showDialog(
                                                                  context:
                                                                      context,
                                                                  barrierDismissible:
                                                                      true,
                                                                  builder:
                                                                      (context) {
                                                                    return Dialog(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .white,
                                                                      insetPadding:
                                                                          const EdgeInsets
                                                                              .all(20),
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(16),
                                                                      ),
                                                                      child:
                                                                          Stack(
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(20.0),
                                                                            child:
                                                                                SizedBox(
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
                                                                                        onPressed: () {
                                                                                          Navigator.of(context).pop();
                                                                                        },
                                                                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                                                                        child: const Text('초기화', style: TextStyle(fontSize: 16)),
                                                                                      ),
                                                                                      const SizedBox(width: 12),
                                                                                      ElevatedButton(
                                                                                        onPressed: () {
                                                                                          Navigator.of(context).pop();
                                                                                        },
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
                                                                            left:
                                                                                10,
                                                                            top:
                                                                                10,
                                                                            child:
                                                                                IconButton(
                                                                              icon: const Icon(Icons.close, color: Colors.black87),
                                                                              onPressed: () {
                                                                                Navigator.of(context).pop();
                                                                              },
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },
                                                                );
                                                                isSettingFocused
                                                                    .value = false;
                                                              }
                                                            },
                                                            child: FittedBox(
                                                              fit: BoxFit
                                                                  .contain,
                                                              child:
                                                                  Image.asset(
                                                                asset,
                                                                gaplessPlayback:
                                                                    true,
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

                                        const VerticalDivider(
                                            width: 1,
                                            thickness: 1,
                                            color: Colors.black26),

                                        // ▶ START / STOP 버튼
                                        Expanded(
                                          flex: 2,
                                          child: LayoutBuilder(
                                            builder: (context, box) {
                                              final double h = box.maxHeight;
                                              final double w = box.maxWidth;
                                              final double size =
                                                  math.min(w, h);

                                              return Stack(
                                                children: [
                                                  Positioned(
                                                    right: 10,
                                                    bottom: 10,
                                                    child:
                                                        ValueListenableBuilder<
                                                            bool>(
                                                      valueListenable: CprLock
                                                          .I.isLocked,
                                                      builder: (context,
                                                          locked, _) {
                                                        return ValueListenableBuilder<
                                                            bool>(
                                                          valueListenable:
                                                              activeMode,
                                                          builder: (context,
                                                              isStart, _) {
                                                            return ValueListenableBuilder<
                                                                bool>(
                                                              valueListenable:
                                                                  isPauseFocused,
                                                              builder: (context,
                                                                  pause, _) {
                                                                String asset;

                                                                if (locked) {
                                                                  asset = isStart
                                                                      ? 'assets/btn_start_disabled.png'
                                                                      : 'assets/btn_stop_disabled.png';
                                                                } else if (isStart) {
                                                                  asset =
                                                                      'assets/btn_start.png';
                                                                } else {
                                                                  asset = pause
                                                                      ? 'assets/btn_start.png'
                                                                      : 'assets/btn_stop.png';
                                                                }

                                                                return GestureDetector(
                                                                  onTap: locked
                                                                      ? null
                                                                      : () async {
                                                                          if (BleService.I.firstConnectedId ==
                                                                              null) {
                                                                            showCenterToast(context, "침대를 연결해주세요");
                                                                            return;
                                                                          }

                                                                          if (isStart ||
                                                                              isPauseFocused.value) {
                                                                            activeMode.value = false;
                                                                            mode = "체압분산";
                                                                            selectedMode.value = "BPD";

                                                                            if (isPauseFocused.value) {
                                                                              isPauseFocused.value = false;
                                                                            }

                                                                            await BleService.I.sendToAllConnected(selectedMode.value.codeUnits);
                                                                          } else {
                                                                            activeMode.value = true;
                                                                            isPauseFocused.value = false;
                                                                            await BleService.I.sendToAllConnected('STOP'.codeUnits);
                                                                            mode = '';
                                                                          }
                                                                        },
                                                                  child:
                                                                      SizedBox(
                                                                    width: size,
                                                                    height:
                                                                        size,
                                                                    child: Image
                                                                        .asset(
                                                                      asset,
                                                                      fit: BoxFit
                                                                          .contain,
                                                                      gaplessPlayback:
                                                                          true,
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
            ],
          );
        }),
      ),
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
