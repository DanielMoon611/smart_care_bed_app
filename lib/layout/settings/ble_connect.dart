import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_care_bed_app/network/ble_service.dart';
import 'package:smart_care_bed_app/value.dart';
import 'package:smart_care_bed_app/app/routes.dart';
import 'package:smart_care_bed_app/core/storage.dart';

class BleConnectPage extends StatefulWidget {
  const BleConnectPage({super.key});

  @override
  State<BleConnectPage> createState() => _BleConnectPageState();
}

class _BleConnectPageState extends State<BleConnectPage> {
  final svc = BleService.I;
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  StreamSubscription<String>? _rxSub;

  @override
  void initState() {
    super.initState();
    svc.addListener(_onChanged);
    svc.startScan();
    _rxSub = svc.rxText$.listen((text) {
      if (!mounted) return;
      final t = text.trim();
      if (t == '연결되었습니다') {
        final m = _messengerKey.currentState;
        m?.hideCurrentSnackBar();
        m?.showSnackBar(
          SnackBar(
            content: const Text('연결되었습니다'),
            duration: const Duration(milliseconds: 900),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          ),
        );
      }
    });
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _rxSub?.cancel();
    svc.removeListener(_onChanged);
    svc.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = svc.items;
    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: '설정으로',
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(AppRoutes.setup);
            },
          ),
          title: const Text('침대 연결'),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(child: Text(svc.isScanning ? 'Scanning…' : 'Idle')),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                await svc.stopScan();
                await svc.startScan();
              },
            ),
            const SizedBox(width: 6),
          ],
        ),
        body: items.isEmpty ? const Center(
          child: Text(
            '연결 방법.\n'
            '1. 침대의 전원과 스마트폰(태블릿)의 블루투스를 켜주세요.\n'
            '2. 현재 화면에서 \'Smart Care Bed\'가 나타나면 오른쪽 \'연결하기\'버튼을 눌러주세요.\n',
          ),
        ) : ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final h = items[i];
            final connected = svc.isConnected(h.remoteId);
            return ListTile(
              key: ValueKey(h.key),
              dense: true,
              title: Text(kFixedName),
              subtitle: h.stableIdHex != null ? Text("StableID: ${h.stableIdHex}") : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!connected)
                    ElevatedButton(
                      onPressed: svc.firstConnectedId == null ? () async {
                        await svc.connect(h.remoteId);
                        await AppStorage.saveLastBleId(h.remoteId);
                      } : null,
                      child: const Text('연결하기'),
                    )
                  else
                    ElevatedButton(
                      onPressed: () async {
                        await svc.disconnect(h.remoteId);

                        activeMode.value = true;
                        isPauseFocused.value = false;
                      },
                      child: const Text('연결끊기'),
                    )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
