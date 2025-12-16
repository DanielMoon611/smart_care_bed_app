import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_care_bed_app/network/ble_service.dart';
import 'package:smart_care_bed_app/app/routes.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  final svc = BleService.I;
  StreamSubscription<String>? _rxSub;

  final List<String> _lines = [];

  final ScrollController _scrollCtrl = ScrollController();

  // 🔴 사용자가 현재 하단에 있는지 여부
  bool _isAtBottom = true;

  static bool _isLikelyText(String s) {
    if (s.isEmpty) return false;
    final r = RegExp(
      r'''^[\x09\x0A\x0D\x20-\x7E가-힣ㄱ-ㅎㅏ-ㅣ·—–“”‘’《》〈〉…•·、，。！？₩\[\]\(\)\{\}:;.,_+\-=/\\@#%^&*|'"~`<> ]+$'''
    );
    return r.hasMatch(s);
  }

  void _scrollToBottom() {
    if (!_scrollCtrl.hasClients) return;
    _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;

    final position = _scrollCtrl.position;
    const threshold = 40.0; // 하단 판정 여유값(px)

    _isAtBottom =
        position.pixels >= position.maxScrollExtent - threshold;
  }

  @override
  void initState() {
    super.initState();

    _scrollCtrl.addListener(_onScroll);

    _rxSub = svc.rxText$.listen((text) {
      if (!mounted) return;
      if (_isLikelyText(text)) {
        setState(() {
          _lines.add(text.trimRight());
          if (_lines.length > 500) {
            _lines.removeRange(0, _lines.length - 500);
          }
        });

        // 🔴 하단에 있을 때만 자동 스크롤
        if (_isAtBottom) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _rxSub?.cancel();
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: '설정으로',
          onPressed: () {
            Navigator.of(context)
                .pushReplacementNamed(AppRoutes.setup);
          },
        ),
        title: const Text('로그'),
        actions: [
          IconButton(
            tooltip: '초기화',
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => setState(() {
              _lines.clear();
            }),
          ),
        ],
      ),
      body: _lines.isEmpty
          ? const Center(child: Text('수신 로그가 없습니다.'))
          : ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _lines.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Text(_lines[i]),
              ),
            ),
    );
  }
}
