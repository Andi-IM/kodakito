import 'package:dartz/dartz.dart';
import 'package:dicoding_story/domain/models/cache/cache.dart';
import 'package:dicoding_story/utils/http_exception.dart';

abstract class CacheRepository {
  Future<void> saveToken({required Cache cache});
  Future<Either<AppException, Cache>> getToken();
  Future<bool> deleteToken();
  Future<bool> hasToken();
}

