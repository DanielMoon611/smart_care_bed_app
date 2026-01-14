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
            backgroundColor: Colors.green,
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

  // ✅ 연결 시도 핸들러
  Future<void> _handleConnect(String remoteId) async {
    try {
      await svc.connect(remoteId);
      await AppStorage.saveLastBleId(remoteId);
      
      if (!mounted) return;
      _messengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('연결 중...'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _messengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('연결 실패: $e'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleDisconnect(String remoteId) async {
    try {
      await svc.disconnect(remoteId);
      activeMode.value = true;
      isPauseFocused.value = false;
      
      if (!mounted) return;
      _messengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('연결이 해제되었습니다'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _messengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text('연결 해제 실패: $e'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = svc.items;
    final hasConnection = svc.firstConnectedId != null;
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
              child: Center(child: Text(svc.isScanning ? 'Scanning…' : 'Idle', style: TextStyle(color: svc.isScanning ? Colors.blue : Colors.grey,),)),
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
        body: Column(
          children: [
            // ✅ 연결 상태 표시
            if (hasConnection)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.green.shade100,
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '현재 연결됨: ${items.firstWhere((h) => h.remoteId == svc.firstConnectedId, orElse: () => items.first).name}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            
            // ✅ 기기 목록
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text(
                          '연결 방법:\n\n'
                          '1. 침대의 전원과 스마트폰(태블릿)의 블루투스를 켜주세요.\n\n'
                          '2. 현재 화면에서 \'Smart Care Bed\'가 나타나면 '
                          '오른쪽 \'연결하기\' 버튼을 눌러주세요.\n\n'
                          '※ 한 번에 하나의 기기만 연결할 수 있습니다.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final h = items[i];
                        final connected = svc.isConnected(h.remoteId);
                        
                        return ListTile(
                          key: ValueKey(h.key),
                          dense: true,
                          tileColor: connected ? Colors.green.shade50 : null,
                          leading: Icon(
                            connected ? Icons.bluetooth_connected : Icons.bluetooth,
                            color: connected ? Colors.green : Colors.grey,
                          ),
                          title: Text(
                            kFixedName,
                            style: TextStyle(
                              fontWeight: connected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: h.stableIdHex != null
                              ? Text("StableID: ${h.stableIdHex}")
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!connected)
                                ElevatedButton(
                                  // ✅ 다른 기기가 연결되어 있으면 비활성화
                                  onPressed: !hasConnection
                                      ? () => _handleConnect(h.remoteId)
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: hasConnection ? Colors.grey : null,
                                  ),
                                  child: const Text('연결하기'),
                                )
                              else
                                ElevatedButton(
                                  onPressed: () => _handleDisconnect(h.remoteId),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('연결끊기'),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
