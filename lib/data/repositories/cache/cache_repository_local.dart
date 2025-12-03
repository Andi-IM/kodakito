import 'package:dicoding_story/data/services/local/cache_datasource.dart';
import 'package:dicoding_story/domain/models/cache/cache.dart';
import 'package:dicoding_story/domain/repository/cache_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dicoding_story/utils/http_exception.dart';

class CacheRepositoryImpl implements CacheRepository {
  final CacheDatasource _datasource;
  CacheRepositoryImpl({required CacheDatasource datasource})
    : _datasource = datasource;

  @override
  Future<void> saveToken({required Cache cache}) =>
      _datasource.saveToken(cache: cache);

  @override
  Future<Either<AppException, Cache>> getToken() => _datasource.getToken();

  @override
  Future<bool> deleteToken() => _datasource.deleteToken();

  @override
  Future<bool> hasToken() => _datasource.hasToken();
}
