import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:smart_care_bed_app/value.dart';
import 'package:smart_care_bed_app/app/routes.dart';
import 'package:smart_care_bed_app/core/storage.dart';
import 'package:smart_care_bed_app/network/ble_service.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPage();
}

class _SetupPage extends State<SetupPage> {
  final ValueNotifier<bool> isInitFocused = ValueNotifier(false);

  late VoidCallback _cprListener;

  @override
  void initState() {
    super.initState();

    _cprListener = () {
      if (!CprLock.I.isLocked.value) {
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
    isInitFocused.dispose();
    CprLock.I.isLocked.removeListener(_cprListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nav = Navigator.of(context);

    return ScaffoldMessenger(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(builder: (context, c) {
          final screenWidth = c.maxWidth;
          final screenHeight = c.maxHeight;
          final titleAreaHeight = screenHeight * 0.2;

          final double titleFontSize = ((screenWidth * 0.042).clamp(24.0, 60.0)).toDouble();
          final double subtitleFontSize = ((screenWidth * 0.030).clamp(18.0, 40.0)).toDouble();

          final double titleBgWidth = screenWidth * 0.78;
          final double titleBgHeight = titleAreaHeight * 0.95;

          return Column(
            children: [
              // ------------------- 상단 타이틀 -------------------
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
                          '설정',
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
                          'Setup',
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

              // ------------------- 설정 카드 영역 -------------------
              Expanded(
                flex: 9,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          alignment: Alignment.topCenter,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildSettingsCard(
                                  title: '언어 설정',
                                  subtitle: '한국어, 영어, 일본어, 중국어',
                                  icon: Icons.language,
                                  color: Colors.blue,
                                  onTap: () => nav.pushReplacementNamed(AppRoutes.language),
                                ),
                                _buildSettingsCard(
                                  title: '침대 연결',
                                  subtitle: '블루투스',
                                  icon: Icons.bluetooth,
                                  color: Colors.green,
                                  onTap: () => nav.pushReplacementNamed(AppRoutes.bleConnect),
                                ),
                                _buildSettingsCard(
                                  title: '사용자 인식',
                                  subtitle: '사용자 인식 ON/OFF',
                                  icon: Icons.sensors,
                                  color: Colors.red,
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
                                        },
                                      );
                                    },
                                  ),
                                ),
                                _buildSettingsCard(
                                  title: '사용자 정보',
                                  subtitle: '사용자 정보 등록',
                                  icon: Icons.account_circle,
                                  color: Colors.amber,
                                  onTap: () => nav.pushReplacementNamed(AppRoutes.userInfo),
                                ),
                                _buildSettingsCard(
                                  title: 'AI 음성 인식',
                                  subtitle: '음성 명령, 스마트 제어',
                                  icon: Icons.mic,
                                  color: Colors.orange,
                                  onTap: () => nav.pushReplacementNamed(AppRoutes.stt),
                                ),
                                _buildSettingsCard(
                                  title: '음원',
                                  subtitle: '음원 관리',
                                  icon: Icons.music_note,
                                  color: Colors.pink,
                                  onTap: () => nav.pushReplacementNamed(AppRoutes.bgm),
                                ),
                                _buildSettingsCard(
                                  title: '욕창 예방 관리 시스템',
                                  subtitle: '실시간 욕창 관리 로그',
                                  icon: Icons.local_hospital,
                                  color: Colors.purple,
                                  onTap: () => nav.pushReplacementNamed(AppRoutes.log),
                                ),
                                _buildSettingsCard(
                                  title: '사용 설명서',
                                  subtitle: '기기 사용법, 안전 주의 사항',
                                  icon: Icons.book,
                                  color: Colors.teal,
                                  onTap: () => nav.pushReplacementNamed(AppRoutes.manual),
                                ),
                                _buildSettingsCard(
                                  title: '자가테스트',
                                  subtitle: '하드웨어 및 소프트웨어 진단',
                                  icon: Icons.build,
                                  color: Colors.indigo,

                                  // -----------------
                                  // SelfTest 진입 제한
                                  // -----------------
                                  onTap: () {
                                    if (BleService.I.firstConnectedId == null) {
                                      showCenterToast(context, "침대를 연결해주세요");
                                      return;
                                    }
                                    if (activeMode.value == false && isPauseFocused.value == false) {
                                      ScaffoldMessenger.of(context)
                                        ..hideCurrentSnackBar()
                                        ..showSnackBar(
                                          const SnackBar(
                                            content: Text("작동 중에는 자가테스트로 이동할 수 없습니다."),
                                            duration: Duration(seconds: 2),
                                            behavior: SnackBarBehavior.floating,
                                            margin: EdgeInsets.fromLTRB(12, 0, 12, 12),
                                          ),
                                        );
                                      return;
                                    }

                                    nav.pushReplacementNamed(AppRoutes.selfTest);
                                  },
                                ),
                                _buildSettingsCard(
                                  title: '고객센터 연결',
                                  subtitle: '전화, 이메일, 방문 상담',
                                  icon: Icons.phone,
                                  color: Colors.brown,
                                  onTap: () => nav.pushReplacementNamed(AppRoutes.help),
                                ),
                                _buildSettingsCard(
                                  title: '모든 설정 초기화',
                                  subtitle: '초기 상태로 되돌리기',
                                  icon: Icons.refresh,
                                  color: Colors.grey,
                                  onTap: () => nav.pushReplacementNamed(AppRoutes.reset),
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
          );
        }),
      ),
    );
  }

  // ---------------------------------------------
  // 공통 카드 생성 함수
  // ---------------------------------------------
  Widget _buildSettingsCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Material(
        elevation: 1,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          tileColor: Colors.white,
          leading: CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          onTap: onTap,
          trailing: trailing,
        ),
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