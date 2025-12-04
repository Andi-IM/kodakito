import 'package:dartz/dartz.dart';
import 'package:dicoding_story/domain/models/cache/cache.dart';
import 'package:dicoding_story/domain/repository/cache_repository.dart';
import 'package:dicoding_story/utils/http_exception.dart';

class FakeCacheRepository extends CacheRepository {
  Cache? _cache;

  @override
  Future<bool> deleteToken() {
    _cache = null;
    return Future.value(true);
  }

  @override
  Future<Either<AppException, Cache>> getToken() {
    if (_cache != null) {
      return Future.value(Right(_cache!));
    } else {
      return Future.value(
        Left(
          AppException(
            message: 'Cache not found',
            statusCode: 404,
            identifier: 'CacheRepository',
          ),
        ),
      );
    }
  }

  @override
  Future<bool> hasToken() {
    // ignore: unnecessary_null_comparison
    return Future.value(_cache != null);
  }

  @override
  Future<bool> saveToken({required Cache cache}) {
    _cache = cache;
    return Future.value(true);
  }
}
