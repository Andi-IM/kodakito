import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dicoding_story/common/globals.dart';
import 'package:dicoding_story/data/services/local/cache_datasource.dart';
import 'package:dicoding_story/data/services/local/storage_service.dart';
import 'package:dicoding_story/domain/models/cache/cache.dart';
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockStorageService extends Mock implements StorageService {}

void main() {
  late CacheDatasourceImpl datasource;
  late MockStorageService mockStorageService;

  setUp(() {
    mockStorageService = MockStorageService();
    datasource = CacheDatasourceImpl(storageService: mockStorageService);
  });

  const tCache = Cache(
    token: 'test_token',
    userName: 'test_user',
    userId: 'test_id',
  );

  group('getToken', () {
    test('should return Cache when storage returns data', () async {
      // Arrange
      when(
        () => mockStorageService.get(CACHE_STORAGE_KEY),
      ).thenAnswer((_) async => jsonEncode(tCache.toJson()));

      // Act
      final result = await datasource.getToken();

      // Assert
      verify(() => mockStorageService.get(CACHE_STORAGE_KEY)).called(1);
      expect(result, const Right(tCache));
    });

    test('should return AppException when storage returns null', () async {
      // Arrange
      when(
        () => mockStorageService.get(CACHE_STORAGE_KEY),
      ).thenAnswer((_) async => null);

      // Act
      final result = await datasource.getToken();

      // Assert
      verify(() => mockStorageService.get(CACHE_STORAGE_KEY)).called(1);
      expect(result.isLeft(), true);
      result.fold((l) {
        expect(l, isA<AppException>());
        expect(l.message, 'Token not found');
        expect(l.statusCode, 404);
      }, (r) => fail('Should return Left'));
    });
  });

  group('saveToken', () {
    test('should call storage.set with correct data', () async {
      // Arrange
      when(
        () => mockStorageService.set(any(), any()),
      ).thenAnswer((_) async => true);

      // Act
      await datasource.saveToken(cache: tCache);

      // Assert
      verify(
        () => mockStorageService.set(
          CACHE_STORAGE_KEY,
          jsonEncode(tCache.toJson()),
        ),
      ).called(1);
    });
  });

  group('deleteToken', () {
    test('should call storage.remove', () async {
      // Arrange
      when(
        () => mockStorageService.remove(any()),
      ).thenAnswer((_) async => true);

      // Act
      await datasource.deleteToken();

      // Assert
      verify(() => mockStorageService.remove(CACHE_STORAGE_KEY)).called(1);
    });
  });

  group('hasToken', () {
    test('should call storage.has', () async {
      // Arrange
      when(() => mockStorageService.has(any())).thenAnswer((_) async => true);

      // Act
      await datasource.hasToken();

      // Assert
      verify(() => mockStorageService.has(CACHE_STORAGE_KEY)).called(1);
    });
  });
}
