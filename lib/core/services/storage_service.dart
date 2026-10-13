import 'package:shared_preferences/shared_preferences.dart';

abstract class StorageService {
  Future<void> init();
  String? getString(String key);
  Future<bool> setString(String key, String value);
  int? getInt(String key);
  Future<bool> setInt(String key, int value);
  bool? getBool(String key);
  Future<bool> setBool(String key, bool value);
  Future<bool> remove(String key);
  Future<bool> clear();
}

class SharedPreferencesStorageService implements StorageService {
  SharedPreferences? _prefs;

  @override
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  String? getString(String key) => _prefs?.getString(key);

  @override
  Future<bool> setString(String key, String value) async {
    await init();
    return await _prefs!.setString(key, value);
  }

  @override
  int? getInt(String key) => _prefs?.getInt(key);

  @override
  Future<bool> setInt(String key, int value) async {
    await init();
    return await _prefs!.setInt(key, value);
  }

  @override
  bool? getBool(String key) => _prefs?.getBool(key);

  @override
  Future<bool> setBool(String key, bool value) async {
    await init();
    return await _prefs!.setBool(key, value);
  }

  @override
  Future<bool> remove(String key) async {
    await init();
    return await _prefs!.remove(key);
  }

  @override
  Future<bool> clear() async {
    await init();
    return await _prefs!.clear();
  }
}

/// In-memory storage mock for fast, isolated unit & widget tests
class MemoryStorageService implements StorageService {
  final Map<String, dynamic> _store = {};

  @override
  Future<void> init() async {}

  @override
  String? getString(String key) => _store[key] as String?;

  @override
  Future<bool> setString(String key, String value) async {
    _store[key] = value;
    return true;
  }

  @override
  int? getInt(String key) => _store[key] as int?;

  @override
  Future<bool> setInt(String key, int value) async {
    _store[key] = value;
    return true;
  }

  @override
  bool? getBool(String key) => _store[key] as bool?;

  @override
  Future<bool> setBool(String key, bool value) async {
    _store[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    _store.remove(key);
    return true;
  }

  @override
  Future<bool> clear() async {
    _store.clear();
    return true;
  }
}
