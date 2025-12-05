import 'package:dartz/dartz.dart';
import 'package:dicoding_story/data/services/local/cache_datasource.dart';
import 'package:dicoding_story/data/services/remote/auth/auth_interceptor.dart';
import 'package:dicoding_story/data/services/remote/auth/model/login_response/login_response.dart';
import 'package:dicoding_story/data/services/remote/auth/model/login_result/login_result.dart';
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCacheDatasource extends Mock implements CacheDatasource {}

class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

void main() {
  late AuthInterceptor authInterceptor;
  late MockCacheDatasource mockCacheDatasource;
  late MockRequestInterceptorHandler mockHandler;

  setUp(() {
    mockCacheDatasource = MockCacheDatasource();
    mockHandler = MockRequestInterceptorHandler();
    authInterceptor = AuthInterceptor(mockCacheDatasource);
  });

  group('AuthInterceptor', () {
    final tLoginResult = LoginResult(
      userId: 'user-id',
      name: 'name',
      token: 'test-token',
    );
    final tLoginResponse = LoginResponse(
      error: false,
      message: 'success',
      loginResult: tLoginResult,
    );

    test('should add Authorization header when token is available', () async {
      // Arrange
      when(
        () => mockCacheDatasource.getToken(),
      ).thenAnswer((_) async => Right(tLoginResponse));
      final options = RequestOptions(path: '/test');

      // Act
      await authInterceptor.onRequest(options, mockHandler);

      // Assert
      verify(() => mockCacheDatasource.getToken()).called(1);
      expect(options.headers['Authorization'], 'Bearer test-token');
      verify(() => mockHandler.next(options)).called(1);
    });

    test(
      'should proceed without adding header when token is not available',
      () async {
        // Arrange
        when(() => mockCacheDatasource.getToken()).thenAnswer(
          (_) async => Left(
            AppException(
              message: 'No token',
              statusCode: 0,
              identifier: 'AuthInterceptor',
            ),
          ),
        );
        final options = RequestOptions(path: '/test');

        // Act
        await authInterceptor.onRequest(options, mockHandler);

        // Assert
        verify(() => mockCacheDatasource.getToken()).called(1);
        expect(options.headers['Authorization'], isNull);
        verify(() => mockHandler.next(options)).called(1);
      },
    );
  });
}
