import 'package:flutter/material.dart';
import 'package:smart_care_bed_app/value.dart';
import 'package:smart_care_bed_app/app/routes.dart';
import 'package:smart_care_bed_app/network/ble_service.dart';

class SelfTestPage extends StatefulWidget {
  const SelfTestPage({super.key});

  @override
  State<SelfTestPage> createState() => _SelfTestPageState();
}

class _SelfTestPageState extends State<SelfTestPage> {
  final List<bool> _isSelected = List.generate(12, (_) => false);
  final ScrollController _scrollController = ScrollController();
  final Map<int, String> _sensorLast = {};
  int? _selectedButtonIndex;
  String _currentMode = '';

  @override
  void initState() {
    super.initState();

    BleService.I.rxText$.listen((data) {
      if (!mounted) return;
      final decoded = data.trim();

      if (decoded.startsWith("SENSOR/") && _currentMode == 'S') {
        try {
          final parts = decoded.split('/');
          if (parts.length < 3) return;
          final key = int.tryParse(parts[1]);
          final csv = parts[2];

          if (key != null && key >= 1 && key <= 12) {
            final formatted = csv
                .split(',')
                .map((s) => s.trim())
                .map((s) => s.padLeft(5, ' '))
                .join(' ');

            setState(() {
              _sensorLast[key] = formatted;
            });

            Future.delayed(const Duration(milliseconds: 100), () {
              if (_scrollController.hasClients) {
                _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
              }
            });
          }
        } catch (e) {
          debugPrint("⚠️ 센서 데이터 파싱 실패: $decoded");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: '설정으로',
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.setup);
            },
          ),
          title: const Text('자가테스트'),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildSectionDivider("건반"),
                    const SizedBox(height: 16),

                    GridView.count(
                      crossAxisCount: 6,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      children: List.generate(12, (index) {
                        final bool selected = _isSelected[index];
                        final bool isDisabled = isTestStartStop.value;

                        return GestureDetector(
                          onTap: () {
                            if (isDisabled) return;
                            setState(() {
                              _isSelected[index] = !_isSelected[index];
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: selected ? Colors.blue[800] : Colors.blue[200],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: selected ? Colors.blue[900]! : Colors.grey.shade400,
                                width: selected ? 2.0 : 1.0,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: selected ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 16),
                    _buildSectionDivider("모드"),
                    const SizedBox(height: 16),

                    // 모드 버튼 4개
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 5.0,
                      children: List.generate(4, (index) {
                        final labels = [
                          '정방향 회전',
                          '역방향 회전',
                          '초기화',
                          '센서 측정',
                        ];
                        return _buildControlButton(context, index, labels[index]);
                      }),
                    ),

                    const SizedBox(height: 24),

                    // 시작 / 정지 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: _buildControlButton(context, 4, '시작 / 정지'),
                    ),

                    const SizedBox(height: 16),

                    // 센서값 표시 영역
                    Container(
                      height: 300,
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(12, (index) {
                                final key = index + 1;
                                final line = _sensorLast[key] ?? '';
                                return Text(
                                  '${key.toString().padLeft(2, ' ')} - $line',
                                  style: const TextStyle(
                                    fontFamily: 'Courier',
                                    fontSize: 16,
                                    height: 1.4,
                                    color: Colors.black87,
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.delete_sweep),
                        label: const Text('Clear'),
                        onPressed: () {
                          setState(() {
                            _sensorLast.clear();
                          });

                          if (_scrollController.hasClients) {
                            _scrollController.jumpTo(0);
                          }

                          _showSnackBar(context, '센서 표시를 초기화했습니다.');
                        },
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 구분선 위젯
  Widget _buildSectionDivider(String title) {
    return Row(
      children: [
        const Expanded(child: Divider(thickness: 1.5, color: Colors.grey)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const Expanded(child: Divider(thickness: 1.5, color: Colors.grey)),
      ],
    );
  }

  /// 제어 버튼
  Widget _buildControlButton(BuildContext context, int index, String label) {
    final bool selected = _selectedButtonIndex == index;
    final bool isStartStopButton = index == 4;

    // 버튼 텍스트 ("시작" / "정지")
    final String dynamicLabel = isStartStopButton ? (isTestStartStop.value ? '정지' : '시작') : label;

    // 색상 정의
    Color baseColor;
    Color borderColor;

    if (isStartStopButton) {
      // 시작: 파랑 / 정지: 빨강
      if (!isTestStartStop.value) {
        baseColor = Colors.blue[800]!;
        borderColor = Colors.blue[900]!;
      } else {
        baseColor = Colors.red[800]!;
        borderColor = Colors.red[900]!;
      }
    } else {
      // 모드 버튼: 선택 파랑, 미선택 연파랑
      baseColor = selected ? Colors.blue[800]! : Colors.blue[200]!;
      borderColor = selected ? Colors.blue[900]! : Colors.grey.shade400;
    }

    final bool isDisabled = isTestStartStop.value && !isStartStopButton && !_isSelectedControl(index);

    return GestureDetector(
      onTap: () async {
        if (isDisabled) return;

        // Start / Stop 버튼 동작
        if (isStartStopButton) {
          final bool hasKeyboardSelected = _isSelected.contains(true);
          final bool hasModeSelected = _selectedButtonIndex != null && _selectedButtonIndex! < 4;

          if (!isTestStartStop.value) {
            if (!hasKeyboardSelected) {
              _showSnackBar(context, "건반 선택");
              return;
            }
            if (!hasModeSelected) {
              _showSnackBar(context, "모드 선택");
              return;
            }

            final selectedIndexes = <String>[];
            for (int i = 0; i < _isSelected.length; i++) {
              if (_isSelected[i]) selectedIndexes.add('${i + 1}');
            }
            final key = selectedIndexes.join(',');

            String mode = '';
            if (_selectedButtonIndex == 0) mode = 'R';
            if (_selectedButtonIndex == 1) mode = 'L';
            if (_selectedButtonIndex == 2) mode = 'I';
            if (_selectedButtonIndex == 3) mode = 'S';
            _currentMode = mode;

            final sendData = 'TEST/$key/$mode';
            await BleService.I.sendToAllConnected(sendData.codeUnits);

            setState(() => isTestStartStop.value = true);
          } else {
            const stopData = 'PAUSE';
            await BleService.I.sendToAllConnected(stopData.codeUnits);

            setState(() {
              isTestStartStop.value = false;
              _selectedButtonIndex = null;
              _currentMode = '';
            });
          }
          return;
        }

        // 모드 버튼 선택/해제
        setState(() {
          _selectedButtonIndex = (_selectedButtonIndex == index) ? null : index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey[400] : baseColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDisabled ? Colors.grey : borderColor,
            width: selected ? 2.0 : 1.0,
          ),
        ),
        child: Center(
          child: Text(
            dynamicLabel,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,

              // ⭐ 변경된 부분: 선택 시 흰색 / 미선택 시 검정
              color: isStartStopButton ? Colors.white : (selected ? Colors.white : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, textAlign: TextAlign.center),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        ),
      );
  }

  bool _isSelectedControl(int index) => _selectedButtonIndex == index && _selectedButtonIndex! < 4;
}
