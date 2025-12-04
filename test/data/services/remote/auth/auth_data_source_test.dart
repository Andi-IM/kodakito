import 'package:dartz/dartz.dart';
import 'package:dicoding_story/data/services/remote/auth/auth_data_source.dart';
import 'package:dicoding_story/data/services/remote/auth/model/default_response/default_response.dart';
import 'package:dicoding_story/data/services/remote/auth/model/login_request/login_request.dart';
import 'package:dicoding_story/data/services/remote/auth/model/login_response/login_response.dart';
import 'package:dicoding_story/data/services/remote/auth/model/register_request/register_request.dart';
import 'package:dicoding_story/data/services/remote/network_service.dart';
import 'package:dicoding_story/domain/models/response.dart' as response;
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockNetworkService extends Mock implements NetworkService {}

void main() {
  late StoryAuthApi dataSource;
  late MockNetworkService mockNetworkService;

  setUp(() {
    mockNetworkService = MockNetworkService();
    dataSource = StoryAuthApi(networkService: mockNetworkService);
  });

  group('StoryAuthApi', () {
    const tRegisterRequest = RegisterRequest(
      name: 'User Name',
      email: 'test@example.com',
      password: 'password',
    );
    const tLoginRequest = LoginRequest(
      email: 'test@example.com',
      password: 'password',
    );
    final tDefaultResponseData = {'error': false, 'message': 'success'};
    final tLoginResponseData = {
      'error': false,
      'message': 'success',
      'loginResult': {
        'userId': 'user-id',
        'name': 'User Name',
        'token': 'token',
      },
    };

    group('register', () {
      test('should return Right(DefaultResponse) when successful', () async {
        // Arrange
        when(
          () => mockNetworkService.post(any(), data: any(named: 'data')),
        ).thenAnswer(
          (_) async => Right(
            response.Response(data: tDefaultResponseData, statusCode: 200),
          ),
        );

        // Act
        final result = await dataSource.register(
          registerRequest: tRegisterRequest,
        );

        // Assert
        expect(result, isA<Right<AppException, DefaultResponse>>());
        verify(
          () => mockNetworkService.post(
            '/register',
            data: any(
              named: 'data',
              that: equals(registerRequestToJson(tRegisterRequest)),
            ),
          ),
        ).called(1);
      });

      test('should return Left(AppException) when failed', () async {
        // Arrange
        final tException = AppException(
          message: 'Error',
          statusCode: 400,
          identifier: 'Error',
        );
        when(
          () => mockNetworkService.post(any(), data: any(named: 'data')),
        ).thenAnswer((_) async => Left(tException));

        // Act
        final result = await dataSource.register(
          registerRequest: tRegisterRequest,
        );

        // Assert
        expect(result, isA<Left<AppException, DefaultResponse>>());
        verify(
          () => mockNetworkService.post(
            '/register',
            data: any(
              named: 'data',
              that: equals(registerRequestToJson(tRegisterRequest)),
            ),
          ),
        ).called(1);
      });

      test('should return Left(AppException) when parsing fails', () async {
        // Arrange
        when(
          () => mockNetworkService.post(any(), data: any(named: 'data')),
        ).thenAnswer(
          (_) async => Right(
            response.Response(
              data: {'invalid': 'json'}, // Missing required fields
              statusCode: 200,
            ),
          ),
        );

        // Act
        final result = await dataSource.register(
          registerRequest: tRegisterRequest,
        );

        // Assert
        expect(result, isA<Left<AppException, DefaultResponse>>());
        result.fold((l) {
          expect(l.message, 'Unknown error occured');
          expect(l.identifier, contains('StoryAuthApi.register'));
        }, (r) => fail('Should return Left'));
      });
    });

    group('login', () {
      test(
        'should return Right(LoginResponse) and update header when successful',
        () async {
          // Arrange
          when(
            () => mockNetworkService.post(any(), data: any(named: 'data')),
          ).thenAnswer(
            (_) async => Right(
              response.Response(data: tLoginResponseData, statusCode: 200),
            ),
          );
          when(() => mockNetworkService.updateHeader(any())).thenReturn(null);

          // Act
          final result = await dataSource.login(tLoginRequest);

          // Assert
          expect(result, isA<Right<AppException, LoginResponse>>());
          verify(
            () => mockNetworkService.post(
              '/login',
              data: any(
                named: 'data',
                that: equals(loginRequestToJson(tLoginRequest)),
              ),
            ),
          ).called(1);
          verify(
            () => mockNetworkService.updateHeader(
              any(that: equals({'Authorization': 'Bearer token'})),
            ),
          ).called(1);
        },
      );

      test('should return Left(AppException) when failed', () async {
        // Arrange
        final tException = AppException(
          message: 'Error',
          statusCode: 400,
          identifier: 'Error',
        );
        when(
          () => mockNetworkService.post(any(), data: any(named: 'data')),
        ).thenAnswer((_) async => Left(tException));

        // Act
        final result = await dataSource.login(tLoginRequest);

        // Assert
        expect(result, isA<Left<AppException, LoginResponse>>());
        verify(
          () => mockNetworkService.post(
            '/login',
            data: any(
              named: 'data',
              that: equals(loginRequestToJson(tLoginRequest)),
            ),
          ),
        ).called(1);
        verifyNever(() => mockNetworkService.updateHeader(any()));
      });

      test('should return Left(AppException) when parsing fails', () async {
        // Arrange
        when(
          () => mockNetworkService.post(any(), data: any(named: 'data')),
        ).thenAnswer(
          (_) async => Right(
            response.Response(
              data: {'invalid': 'json'}, // Missing required fields
              statusCode: 200,
            ),
          ),
        );

        // Act
        final result = await dataSource.login(tLoginRequest);

        // Assert
        expect(result, isA<Left<AppException, LoginResponse>>());
        result.fold((l) {
          expect(l.message, 'Unknown error occured');
          expect(l.identifier, contains('StoryAuthApi.login'));
        }, (r) => fail('Should return Left'));
      });
    });
  });
}
