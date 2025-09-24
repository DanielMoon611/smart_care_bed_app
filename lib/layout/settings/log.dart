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
  final _lines = <String>[];
  String _last = '';

  static bool _isLikelyText(String s) {
    if (s.isEmpty) return false;
    final r = RegExp(
      r'''^[\x09\x0A\x0D\x20-\x7E가-힣ㄱ-ㅎㅏ-ㅣ·—–“”‘’《》〈〉…•·、，。！？₩\[\]\(\)\{\}:;.,_+\-=/\\@#%^&*|'"~`<> ]+$'''
    );
    return r.hasMatch(s);
  }

  @override
  void initState() {
    super.initState();
    _rxSub = svc.rxText$.listen((text) {
      if (!mounted) return;
      final decoded = text;
      if (_isLikelyText(decoded)) {
        setState(() {
          _last = decoded.trimRight();
          _lines.add(_last);
          if (_lines.length > 500) {
            _lines.removeRange(0, _lines.length - 500);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _rxSub?.cancel();
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
            Navigator.of(context).pushReplacementNamed(AppRoutes.setup);
          },
        ),
        title: const Text('로그'),
        actions: [
          IconButton(
            tooltip: '초기화',
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => setState(() {
              _lines.clear();
              _last = '';
            }),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              _last.isEmpty ? ' ' : _last,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ),
        ),
      ),
      body: _lines.isEmpty ? const Center(child: Text('수신 로그가 없습니다.')) : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _lines.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(_lines[i]),
        ),
      ),
    );
  }
}