import 'dart:async';

import 'package:dicoding_story/data/services/api/local/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService implements StorageService {
  SharedPreferences? prefs;

  final Completer<SharedPreferences> initCompleter =
      Completer<SharedPreferences>();

  @override
  void init() {
    final future = SharedPreferences.getInstance();
    initCompleter.complete(future);
    future.then((value) => prefs = value);
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
  Future<bool> set(String key, data) async {
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
