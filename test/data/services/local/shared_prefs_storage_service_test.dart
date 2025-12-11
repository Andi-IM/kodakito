import 'package:dicoding_story/data/services/api/local/shared_prefs_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPrefsService service;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    service = SharedPrefsService();
  });

  test('init should initialize SharedPreferences', () async {
    service.init();
    await service.initCompleter.future;
    await Future.delayed(Duration.zero);
    expect(service.hasInitialized, true);
  });

  test('set and get should work', () async {
    service.init();
    await service.set('key', 'value');
    final result = await service.get('key');
    expect(result, 'value');
  });

  test('remove should work', () async {
    service.init();
    await service.set('key', 'value');
    await service.remove('key');
    final result = await service.get('key');
    expect(result, null);
  });

  test('clear should work', () async {
    service.init();
    await service.set('key1', 'value1');
    await service.set('key2', 'value2');
    await service.clear();
    expect(await service.get('key1'), null);
    expect(await service.get('key2'), null);
  });

  test('has should work', () async {
    service.init();
    await service.set('key', 'value');
    expect(await service.has('key'), true);
    await service.remove('key');
    expect(await service.has('key'), false);
  });
}
