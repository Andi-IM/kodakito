import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dicoding_story/common/globals.dart';
import 'package:dicoding_story/data/services/local/storage_service.dart';
import 'package:dicoding_story/domain/models/cache/cache.dart';
import 'package:dicoding_story/utils/http_exception.dart';

abstract class CacheDatasource {
  String get key;
  Future<Either<AppException, Cache>> getToken();
  Future<bool> saveToken({required Cache cache});
  Future<bool> deleteToken();
  Future<bool> hasToken();
}

class CacheDatasourceImpl implements CacheDatasource {
  CacheDatasourceImpl({required this.storageService});
  final StorageService storageService;

  @override
  String get key => CACHE_STORAGE_KEY;

  @override
  Future<Either<AppException, Cache>> getToken() async {
    final value = await storageService.get(key);
    if (value == null) {
      return Left(
        AppException(
          message: "Token not found",
          statusCode: 404,
          identifier: 'CacheDatasourceImpl.getToken',
        ),
      );
    }
    return Right(Cache.fromJson(jsonDecode(value as String)));
  }

  @override
  Future<bool> saveToken({required Cache cache}) async =>
      await storageService.set(key, jsonEncode(cache.toJson()));

  @override
  Future<bool> deleteToken() async => await storageService.remove(key);

  @override
  Future<bool> hasToken() async => await storageService.has(key);
}
