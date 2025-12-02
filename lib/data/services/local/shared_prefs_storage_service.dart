import 'dart:async';

import 'package:dicoding_story/data/services/local/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService implements StorageService {
  SharedPreferences? prefs;

  final Completer<SharedPreferences> initCompleter =
      Completer<SharedPreferences>();

  @override
  void init() {
    initCompleter.complete(SharedPreferences.getInstance());
  }

  @override
  bool get hasInitialized => prefs != null;

  @override
  Future<bool> remove(String key) async {
    prefs = await initCompleter.future;
    return prefs!.remove(key);
  }

  @override
  Future<Object?> get(String key) async {
    prefs = await initCompleter.future;
    return prefs?.get(key);
  }

  @override
  Future<bool> set(String key, Object data) async {
    prefs = await initCompleter.future;
    return prefs!.setString(key, data.toString());
  }

  @override
  Future<void> clear() async {
    prefs = await initCompleter.future;
    prefs!.clear();
  }

  @override
  Future<bool> has(String key) async {
    prefs = await initCompleter.future;
    return prefs?.containsKey(key) ?? false;
  }
}
