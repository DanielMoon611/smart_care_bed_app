import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  static const _keyUserCheck = 'usercheck';
  static const _keyLastBleId = 'last_ble_id';
  static const _keyLastStableId = 'last_stable_id';

  // usercheck 값 저장
  static Future<void> saveUserCheck(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserCheck, value);
  }

  // usercheck 불러오기
  static Future<int> loadUserCheck() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserCheck) ?? 0;
  }

  // BLE 기기 ID 저장
  static Future<void> saveLastBleId(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastBleId, deviceId);
  }

  // BLE 기기 ID 불러오기
  static Future<String?> loadLastBleId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastBleId);
  }

  // StableID 저장
  static Future<void> saveLastStableId(String stableId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastStableId, stableId);
  }

  // StableID 불러오기
  static Future<String?> loadLastStableId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastStableId);
  }
}