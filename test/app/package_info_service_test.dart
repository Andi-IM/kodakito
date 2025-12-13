import 'package:dicoding_story/app/package_info_service.dart';
import 'package:flutter_test/flutter_test.dart';

class FakePackageInfoService extends Fake implements PackageInfoService {}

void main() {
  group('generated code coverage', () {
    test('PackageInfoProvider overrideWithValue returns Override', () {
      final mockService = FakePackageInfoService();
      final override = packageInfoProvider.overrideWithValue(mockService);
      expect(override, isNotNull);
    });

    test('PackageInfoProvider toString contains provider name', () {
      expect(packageInfoProvider.toString(), contains('packageInfoProvider'));
    });
  });
}
