import 'package:dartz/dartz.dart';
import 'package:dicoding_story/data/repositories/auth/auth_repository_remote.dart';
import 'package:dicoding_story/data/services/remote/auth/auth_data_source.dart';
import 'package:dicoding_story/data/services/remote/auth/model/default_response/default_response.dart';
import 'package:dicoding_story/data/services/remote/auth/model/login_request/login_request.dart';
import 'package:dicoding_story/data/services/remote/auth/model/login_response/login_response.dart';
import 'package:dicoding_story/data/services/remote/auth/model/register_request/register_request.dart';
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthDataSource extends Mock implements AuthDataSource {}

class FakeRegisterRequest extends Fake implements RegisterRequest {}

class FakeLoginRequest extends Fake implements LoginRequest {}

void main() {
  late AuthRepositoryRemote authRepository;
  late MockAuthDataSource mockAuthDataSource;

  setUpAll(() {
    registerFallbackValue(FakeRegisterRequest());
    registerFallbackValue(FakeLoginRequest());
  });

  setUp(() {
    mockAuthDataSource = MockAuthDataSource();
    authRepository = AuthRepositoryRemote(authDataSource: mockAuthDataSource);
  });

  group('AuthRepositoryRemote', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password';
    const tName = 'Test User';

    group('register', () {
      final tRegisterRequest = RegisterRequest(
        email: tEmail,
        password: tPassword,
        name: tName,
      );
      final tDefaultResponse = DefaultResponse(
        error: false,
        message: 'success',
      );

      test(
        'should return Right(DefaultResponse) when dataSource.register is successful',
        () async {
          // Arrange
          when(
            () => mockAuthDataSource.register(
              registerRequest: any(named: 'registerRequest'),
            ),
          ).thenAnswer((_) async => Right(tDefaultResponse));

          // Act
          final result = await authRepository.register(
            email: tEmail,
            password: tPassword,
            name: tName,
          );

          // Assert
          expect(result, Right(tDefaultResponse));
          verify(
            () =>
                mockAuthDataSource.register(registerRequest: tRegisterRequest),
          ).called(1);
        },
      );

      test(
        'should return Left(AppException) when dataSource.register fails',
        () async {
          // Arrange
          final tException = AppException(
            message: 'error',
            statusCode: 400,
            identifier: 'register',
          );
          when(
            () => mockAuthDataSource.register(
              registerRequest: any(named: 'registerRequest'),
            ),
          ).thenAnswer((_) async => Left(tException));

          // Act
          final result = await authRepository.register(
            email: tEmail,
            password: tPassword,
            name: tName,
          );

          // Assert
          expect(result, Left(tException));
          verify(
            () =>
                mockAuthDataSource.register(registerRequest: tRegisterRequest),
          ).called(1);
        },
      );
    });

    group('login', () {
      final tLoginRequest = LoginRequest(email: tEmail, password: tPassword);
      final tLoginResponse = LoginResponse(
        error: false,
        message: 'success',
        loginResult: LoginResult(userId: '1', name: 'Test', token: 'token'),
      );

      test(
        'should return Right(LoginResponse) when dataSource.login is successful',
        () async {
          // Arrange
          when(
            () => mockAuthDataSource.login(any()),
          ).thenAnswer((_) async => Right(tLoginResponse));

          // Act
          final result = await authRepository.login(
            email: tEmail,
            password: tPassword,
          );

          // Assert
          expect(result, Right(tLoginResponse));
          verify(() => mockAuthDataSource.login(tLoginRequest)).called(1);
        },
      );

      test(
        'should return Left(AppException) when dataSource.login fails',
        () async {
          // Arrange
          final tException = AppException(
            message: 'error',
            statusCode: 400,
            identifier: 'login',
          );
          when(
            () => mockAuthDataSource.login(any()),
          ).thenAnswer((_) async => Left(tException));

          // Act
          final result = await authRepository.login(
            email: tEmail,
            password: tPassword,
          );

          // Assert
          expect(result, Left(tException));
          verify(() => mockAuthDataSource.login(tLoginRequest)).called(1);
        },
      );
    });
  });
}
