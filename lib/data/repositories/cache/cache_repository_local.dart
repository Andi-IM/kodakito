import 'package:dicoding_story/domain/models/cache/cache.dart';
import 'package:dicoding_story/domain/repository/cache_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dicoding_story/utils/http_exception.dart';

class CacheRepositoryImpl implements CacheRepository {
  @override
  Future<void> saveToken({required Cache cache}) {
    throw UnimplementedError();
  }

  @override
  Future<Either<AppException, Cache>> getToken() {
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteToken() {
    throw UnimplementedError();
  }

  @override
  Future<bool> hasToken() {
    throw UnimplementedError();
  }
}
