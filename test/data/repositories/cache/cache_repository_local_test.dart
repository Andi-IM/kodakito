import 'package:dartz/dartz.dart';
import 'package:dicoding_story/data/repositories/cache/cache_repository_local.dart';
import 'package:dicoding_story/data/services/local/cache_datasource.dart';
import 'package:dicoding_story/domain/models/cache/cache.dart';
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCacheDatasource extends Mock implements CacheDatasource {}

void main() {
  late CacheRepositoryImpl repository;
  late MockCacheDatasource mockDatasource;

  setUp(() {
    mockDatasource = MockCacheDatasource();
    repository = CacheRepositoryImpl(datasource: mockDatasource);
  });

  const tCache = Cache(
    token: 'test_token',
    userName: 'test_user',
    userId: 'test_id',
  );

  group('saveToken', () {
    test('should call datasource.saveToken and return void', () async {
      // Arrange
      when(
        () => mockDatasource.saveToken(cache: tCache),
      ).thenAnswer((_) async => true);

      // Act
      await repository.saveToken(cache: tCache);

      // Assert
      verify(() => mockDatasource.saveToken(cache: tCache)).called(1);
    });
  });

  group('getToken', () {
    test('should return Cache when datasource returns success', () async {
      // Arrange
      when(
        () => mockDatasource.getToken(),
      ).thenAnswer((_) async => const Right(tCache));

      // Act
      final result = await repository.getToken();

      // Assert
      verify(() => mockDatasource.getToken()).called(1);
      expect(result, const Right(tCache));
    });

    test(
      'should return AppException when datasource returns failure',
      () async {
        // Arrange
        final tException = AppException(
          message: 'Token not found',
          statusCode: 404,
          identifier: 'CacheDatasourceImpl.getToken',
        );
        when(
          () => mockDatasource.getToken(),
        ).thenAnswer((_) async => Left(tException));

        // Act
        final result = await repository.getToken();

        // Assert
        verify(() => mockDatasource.getToken()).called(1);
        expect(result, Left(tException));
      },
    );
  });

  group('deleteToken', () {
    test(
      'should return true when datasource.deleteToken returns true',
      () async {
        // Arrange
        when(() => mockDatasource.deleteToken()).thenAnswer((_) async => true);

        // Act
        final result = await repository.deleteToken();

        // Assert
        verify(() => mockDatasource.deleteToken()).called(1);
        expect(result, true);
      },
    );

    test(
      'should return false when datasource.deleteToken returns false',
      () async {
        // Arrange
        when(() => mockDatasource.deleteToken()).thenAnswer((_) async => false);

        // Act
        final result = await repository.deleteToken();

        // Assert
        verify(() => mockDatasource.deleteToken()).called(1);
        expect(result, false);
      },
    );
  });

  group('hasToken', () {
    test('should return true when datasource.hasToken returns true', () async {
      // Arrange
      when(() => mockDatasource.hasToken()).thenAnswer((_) async => true);

      // Act
      final result = await repository.hasToken();

      // Assert
      verify(() => mockDatasource.hasToken()).called(1);
      expect(result, true);
    });

    test(
      'should return false when datasource.hasToken returns false',
      () async {
        // Arrange
        when(() => mockDatasource.hasToken()).thenAnswer((_) async => false);

        // Act
        final result = await repository.hasToken();

        // Assert
        verify(() => mockDatasource.hasToken()).called(1);
        expect(result, false);
      },
    );
  });
}
