import 'package:freezed_annotation/freezed_annotation.dart';

part 'cache.freezed.dart';
part 'cache.g.dart';

@freezed
abstract class Cache with _$Cache {
  const factory Cache({
    required String token,
    required String userName,
    required String userId,
  }) = _Cache;

  factory Cache.fromJson(Map<String, Object?> json) => _$CacheFromJson(json);
}
