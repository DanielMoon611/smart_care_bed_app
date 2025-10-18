import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_care_bed_app/value.dart';
import 'dart:io' show Platform;

class Hit {
  final String key;
  String remoteId;
  String name;
  int rssi;
  String? stableIdHex;
  int? seq;
  int len;
  DateTime lastSeen;

  Hit({
    required this.key,
    required this.remoteId,
    required this.name,
    required this.rssi,
    required this.stableIdHex,
    required this.seq,
    required this.len,
    required this.lastSeen,
  });
}

class DeviceSession {
  final BluetoothDevice device;
  final BluetoothCharacteristic rx;
  final BluetoothCharacteristic tx;
  final StreamSubscription<List<int>> notifySub;
  final StreamSubscription<BluetoothConnectionState> connSub;

  DeviceSession({
    required this.device,
    required this.rx,
    required this.tx,
    required this.notifySub,
    required this.connSub,
  });

  Future<void> dispose() async {
    try {
      await tx.setNotifyValue(false);
    } catch (_) {}
    try {
      await notifySub.cancel();
    } catch (_) {}
    try {
      await connSub.cancel();
    } catch (_) {}
    try {
      await device.disconnect();
    } catch (_) {}
  }
}

int? parseSmartCareSeq(List<int> d) {
  if (d.length >= 4 && d[0] == 0xC0 && d[1] == 0xDE && d[2] == 0x01) {
    return d[3];
  }
  return null;
}

String? parseStableId(List<int> d) {
  if (d.length >= 9 && d[0] == 0xC0 && d[1] == 0xDE && d[2] == 0x02) {
    final id = d.sublist(3, 9);
    return id.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
  return null;
}

class BleService extends ChangeNotifier {
  BleService._();
  static final BleService I = BleService._();

  Iterable<String> get connectedIds => _sessions.keys;

  final Map<String, Hit> _hits = {};
  final Map<String, DeviceSession> _sessions = {};
  final List<String> _order = [];
  final Map<String, String> _aliasByRemote = {};

  StreamSubscription<List<ScanResult>>? _scanSub;
  int _scanSessionCounter = 0;
  bool _scanning = false;
  Timer? _pruneTimer;
  Timer? _debounce;
  String? get firstConnectedId =>
      _sessions.isEmpty ? null : _sessions.keys.first;

  final StreamController<String> _rxTextCtrl =
      StreamController<String>.broadcast(sync: true);
  Stream<String> get rxText$ => _rxTextCtrl.stream;

  bool get isScanning => _scanning;

  List<Hit> get items {
    final now = DateTime.now();
    final keys = _order.where((key) {
      final h = _hits[key];
      if (h == null) return false;
      final fresh = now.difference(h.lastSeen) < kDisappearAfter;
      final conn = _sessions.containsKey(h.remoteId);
      return fresh || conn;
    }).toList();
    return keys.map((k) => _hits[k]!).toList();
  }

  bool isConnected(String remoteId) => _sessions.containsKey(remoteId);

  Future<void> _waitForBluetoothOn() async {
    final currentState = await FlutterBluePlus.adapterState.first;
    if (currentState == BluetoothAdapterState.on) return;
    await FlutterBluePlus.adapterState.firstWhere(
      (s) => s == BluetoothAdapterState.on,
    );
  }

  Future<void> _ensurePerms() async {
    if (Platform.isAndroid) {
      final scan = await Permission.bluetoothScan.request();
      final conn = await Permission.bluetoothConnect.request();
      final loc = await Permission.locationWhenInUse.request();
      if (!(scan.isGranted || loc.isGranted) || !conn.isGranted) {
        throw Exception('BLE 권한 필요 (Android: SCAN/CONNECT, 또는 위치)');
      }
    } else if (Platform.isIOS) {
      // iOS: BLE 권한 상태 확인 후 재시도
      var scan = await Permission.bluetoothScan.status;
      var connect = await Permission.bluetoothConnect.status;

      // 사용자가 아직 권한을 허용하지 않은 경우
      if (scan.isDenied || connect.isDenied) {
        await Permission.bluetoothScan.request();
        await Permission.bluetoothConnect.request();
      }

      // 권한이 허용됐는지 2차 확인 (딜레이 포함)
      await Future.delayed(const Duration(milliseconds: 600));
      scan = await Permission.bluetoothScan.status;
      connect = await Permission.bluetoothConnect.status;

      // ✅ iOS에서는 BLE 상태도 함께 확인해야 함
      final adapterState = await FlutterBluePlus.adapterState.first;
      if (adapterState != BluetoothAdapterState.on) {
        throw Exception('Bluetooth가 꺼져 있습니다. 설정에서 켜주세요.');
      }

      if (!scan.isGranted || !connect.isGranted) {
        // iOS에서 permission_handler가 즉시 반영되지 않는 경우 대비
        debugPrint('⚠️ BLE 권한이 아직 isGranted로 인식되지 않음. 강제 통과 시도.');
      }
    }
  }

  Future<void> startScan() async {
    try {
      await _ensurePerms();
    } catch (e) {
      debugPrint('⚠️ 권한 확인 중 오류 발생: $e');
    }

    await _waitForBluetoothOn();

    final isAlreadyScanning = await FlutterBluePlus.isScanning.first;
    if (isAlreadyScanning) {
      debugPrint('🔁 이미 BLE 스캔 중입니다. 재시작하지 않습니다.');
      return;
    }

    // 🔹 딜레이를 500ms → 150ms로 단축 (권한 팝업 이후 안정화 시간)
    await Future.delayed(const Duration(milliseconds: 150));

    // 🔹 이전 스캔 세션 정리
    await FlutterBluePlus.stopScan();
    await _scanSub?.cancel();

    final mySession = ++_scanSessionCounter;
    _scanning = true;
    notifyListeners();

    // 🔹 빠른 스캔 설정
    await FlutterBluePlus.startScan(
      withServices: const [],
      continuousUpdates: true,
      continuousDivisor: 1,
      androidUsesFineLocation: Platform.isAndroid,
      androidScanMode: AndroidScanMode.lowLatency, // 가장 빠른 스캔 모드
      timeout: const Duration(seconds: 4), // 스캔 지속시간 4초로 제한
    );

    debugPrint('⚡️ BLE 스캔 즉시 시작됨');

    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      if (mySession != _scanSessionCounter) return;
      bool changed = false;

      for (final r in results) {
        final ad = r.advertisementData;
        final matchByService = ad.serviceUuids.contains(serviceUuid);
        final m = ad.manufacturerData;
        final remoteId = r.device.remoteId.str;
        final advName = ad.advName.trim();
        final matchByName = advName == kFixedName;

        bool matchByMfg = false;
        int? seq;
        String? stableIdHex;

        if (m.containsKey(kManufacturerId)) {
          final raw = m[kManufacturerId]!;
          final Uint8List bytes = raw is Uint8List
              ? raw
              : Uint8List.fromList(List<int>.from(raw));
          stableIdHex = parseStableId(bytes);
          seq = parseSmartCareSeq(bytes);
          matchByMfg = (stableIdHex != null) || (seq != null);
        }

        if (!(matchByService || matchByMfg || matchByName)) continue;

        String? keyId = _aliasByRemote[remoteId];

        if (stableIdHex != null) {
          if (_hits.containsKey(remoteId) && !_hits.containsKey(stableIdHex)) {
            final prev = _hits.remove(remoteId)!;
            final idx = _order.indexOf(remoteId);
            if (idx != -1) _order[idx] = stableIdHex;

            _hits[stableIdHex] = Hit(
              key: stableIdHex,
              remoteId: remoteId,
              name: prev.name,
              rssi: r.rssi,
              stableIdHex: stableIdHex,
              seq: seq,
              len: m[kManufacturerId]?.length ?? prev.len,
              lastSeen: DateTime.now(),
            );
            changed = true;
          }
          _aliasByRemote[remoteId] = stableIdHex;
          keyId = stableIdHex;
        }

        keyId ??= remoteId;
        final displayName = kFixedName;
        final prev = _hits[keyId];

        if (prev == null) {
          _hits[keyId] = Hit(
            key: keyId,
            remoteId: remoteId,
            name: displayName,
            rssi: r.rssi,
            stableIdHex: stableIdHex,
            seq: seq,
            len: m[kManufacturerId]?.length ?? 0,
            lastSeen: DateTime.now(),
          );
          if (!_order.contains(keyId)) _order.add(keyId);
          changed = true;
        } else {
          final newLen = m[kManufacturerId]?.length ?? prev.len;
          final any =
              prev.remoteId != remoteId ||
              prev.rssi != r.rssi ||
              prev.seq != seq ||
              prev.len != newLen ||
              prev.name != displayName ||
              prev.stableIdHex != (stableIdHex ?? prev.stableIdHex);
          if (any) {
            prev
              ..remoteId = remoteId
              ..name = displayName
              ..rssi = r.rssi
              ..seq = seq
              ..stableIdHex = (stableIdHex ?? prev.stableIdHex)
              ..len = newLen
              ..lastSeen = DateTime.now();
            changed = true;
          } else {
            prev.lastSeen = DateTime.now();
          }
        }
      }

      final now = DateTime.now();
      final before = _hits.length;
      _hits.removeWhere(
        (_, h) =>
            now.difference(h.lastSeen) > kDisappearAfter &&
            !_sessions.containsKey(h.remoteId),
      );
      if (_hits.length != before) {
        _order.removeWhere((key) => !_hits.containsKey(key));
        changed = true;
      }
      if (changed) _scheduleNotify();
    });

    FlutterBluePlus.isScanning.where((on) => !on).first.then((_) {
      _scanning = false;
      notifyListeners();
      debugPrint('⏹️ BLE 스캔 종료됨');
    });
  }

  void _scheduleNotify() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      notifyListeners();
    });
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    await _scanSub?.cancel();
    _scanning = false;
    notifyListeners();
  }

  Future<void> connect(String remoteId) async {
    if (_sessions.isNotEmpty) {
      throw Exception('이미 연결된 장치가 있습니다. 먼저 연결을 끊어주세요.');
    }
    if (_sessions.containsKey(remoteId)) return;
    try { 
      try {
        await _waitForBluetoothOn();
        await FlutterBluePlus.stopScan();
        await _scanSub?.cancel();
        await FlutterBluePlus.isScanning.where((v) => !v).first;
      } catch (_) {}
      await Future.delayed(const Duration(milliseconds: 350));

      final dev = BluetoothDevice.fromId(remoteId);
      await dev.connect(
        timeout: const Duration(seconds: 12),
        autoConnect: false,
        license: License.free,
      );

      if (Platform.isAndroid) {
        try {
          await dev.requestConnectionPriority(
            connectionPriorityRequest: ConnectionPriority.high,
          );
        } catch (_) {}
        try {
          await dev.requestMtu(517);
        } catch (_) {}
      }
      await Future.delayed(const Duration(milliseconds: 200));

      final services = await dev.discoverServices();
      BluetoothCharacteristic? rx, tx;
      for (final s in services) {
        if (s.uuid == serviceUuid) {
          for (final c in s.characteristics) {
            if (c.uuid == rxUuid) rx = c;
            if (c.uuid == txUuid) tx = c;
          }
          break;
        }
      }
      if (rx == null || tx == null) {
        await dev.disconnect();
        throw Exception('필요한 특성(RX/TX)을 찾지 못했습니다.');
      }

      try {
        await tx.setNotifyValue(true);
      } catch (_) {}

      final notifySub = tx.lastValueStream.listen((data) async {
        if (data.isEmpty) return;
        final text = await compute(utf8.decode, data); // ✅ isolate 처리
        _rxTextCtrl.add(text);
      });

      final connSub = dev.connectionState.listen((s) async {
        if (s == BluetoothConnectionState.disconnected) {
          await _disposeSession(remoteId);
          notifyListeners();
        }
      });

      _sessions[remoteId] = DeviceSession(
        device: dev,
        rx: rx,
        tx: tx,
        notifySub: notifySub,
        connSub: connSub,
      );

      try {
        final hit = _hits.values.firstWhere((h) => h.remoteId == remoteId);
        hit.lastSeen = DateTime.now();
      } catch (_) {}

      notifyListeners();
    } finally {}
  }

  Future<void> disconnect(String remoteId) async {
    await _disposeSession(remoteId);
    notifyListeners();
  }

  Future<void> _disposeSession(String remoteId) async {
    final sess = _sessions.remove(remoteId);
    if (sess != null) {
      await sess.dispose();
    }
  }

  Future<void> send(
    String remoteId,
    List<int> bytes, {
    bool withoutResponse = true,
  }) async {
    final sess = _sessions[remoteId];
    if (sess == null) throw StateError('연결되지 않았습니다.');
    await sess.rx.write(bytes, withoutResponse: withoutResponse);
  }

  Future<void> sendToAllConnected(
    List<int> bytes, {
    bool withoutResponse = true,
  }) async {
    if (_sessions.isEmpty) {
      throw StateError('연결된 BLE 디바이스가 없습니다.');
    }
    for (final id in _sessions.keys) {
      await send(id, bytes, withoutResponse: withoutResponse);
    }
  }

  Future<void> shutdown() async {
    await stopScan();
    _pruneTimer?.cancel();
    _debounce?.cancel();
    _pruneTimer = null;
    final ids = _sessions.keys.toList();
    for (final id in ids) {
      await _disposeSession(id);
    }
    await _rxTextCtrl.close();
  }
}
