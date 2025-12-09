import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'package_info_service.g.dart';

@riverpod
PackageInfoService packageInfo(Ref ref) => PackageInfoServiceImpl();

abstract class PackageInfoService {
  Future<PackageInfo> getAppVersion();
}

class PackageInfoServiceImpl implements PackageInfoService {
  @override
  Future<PackageInfo> getAppVersion() async {
    return await PackageInfo.fromPlatform();
  }
}

@riverpod
Future<String> version(Ref ref) async {
  final packageInfo = await ref.read(packageInfoProvider).getAppVersion();
  return '${packageInfo.version}+${packageInfo.buildNumber}';
}
