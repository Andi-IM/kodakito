import 'package:dartz/dartz.dart';
import 'package:dicoding_story/domain/models/cache/cache.dart';
import 'package:dicoding_story/data/services/api/remote/auth/model/default_response/default_response.dart';
import 'package:dicoding_story/data/services/api/remote/auth/model/login_response/login_response.dart';
import 'package:dicoding_story/domain/domain_providers.dart';
import 'package:dicoding_story/domain/repository/auth_repository.dart';
import 'package:dicoding_story/domain/repository/cache_repository.dart';
import 'package:dicoding_story/ui/auth/view_models/auth_state.dart';
import 'package:dicoding_story/ui/auth/view_models/auth_view_model.dart';
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// A simple listener to track state changes in Riverpod
class Listener<T> extends Mock {
  void call(T? previous, T next);
}

void main() {
  // Define variables used across tests
  late ProviderContainer container;
  late MockAuthRepository mockAuthRepository;
  late MockCacheRepository mockCacheRepository;
  late Listener<AuthState> authListener;

  setUp(() {
    // 1. Initialize Mocks
    mockAuthRepository = MockAuthRepository();
    mockCacheRepository = MockCacheRepository();
    authListener = Listener<AuthState>();
    registerFallbackValue(
      const Cache(userId: 'id', userName: 'name', token: 'token'),
    );

    // 2. Create ProviderContainer with Overrides
    // We replace the real providers with our mocks so the Notifier uses them.
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
        cacheRepositoryProvider.overrideWithValue(mockCacheRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('LoginNotifier', () {
    const email = 'test@example.com';
    const password = 'password';
    const loginResult = LoginResult(
      userId: 'user-id',
      name: 'User Name',
      token: 'token',
    );
    const loginResponse = LoginResponse(
      error: false,
      message: 'success',
      loginResult: loginResult,
    );

    test('initial state is AuthState.initial', () {
      final state = container.read(loginProvider);
      expect(state, const AuthState.initial());
    });

    test('login success updates state to loaded', () async {
      // Arrange
      when(
        () => mockAuthRepository.login(email: email, password: password),
      ).thenAnswer((_) async => const Right(loginResponse));
      when(
        () => mockCacheRepository.saveToken(cache: any(named: 'cache')),
      ).thenAnswer((_) async => true);

      container.listen(loginProvider, authListener.call, fireImmediately: true);

      // Act
      await container
          .read(loginProvider.notifier)
          .login(email: email, password: password);

      // Assert
      verifyInOrder([
        () => authListener(null, const AuthState.initial()),
        () =>
            authListener(const AuthState.initial(), const AuthState.loading()),
        () => authListener(const AuthState.loading(), const AuthState.loaded()),
      ]);
      verify(
        () => mockAuthRepository.login(email: email, password: password),
      ).called(1);
      verify(
        () => mockCacheRepository.saveToken(cache: any(named: 'cache')),
      ).called(1);
    });

    test('login failure updates state to failure', () async {
      // Arrange
      final exception = AppException(
        message: 'Login failed',
        statusCode: 1,
        identifier: 'login',
      );
      when(
        () => mockAuthRepository.login(email: email, password: password),
      ).thenAnswer((_) async => exception.loginToLeft());

      container.listen(loginProvider, authListener.call, fireImmediately: true);

      // Act
      await container
          .read(loginProvider.notifier)
          .login(email: email, password: password);

      // Assert
      verifyInOrder([
        () => authListener(null, const AuthState.initial()),
        () =>
            authListener(const AuthState.initial(), const AuthState.loading()),
        () => authListener(
          const AuthState.loading(),
          AuthState.failure(exception),
        ),
      ]);
      verify(
        () => mockAuthRepository.login(email: email, password: password),
      ).called(1);
      verifyNever(
        () => mockCacheRepository.saveToken(cache: any(named: 'cache')),
      );
    });

    test(
      'login success but save token fails updates state to failure',
      () async {
        // Arrange
        when(
          () => mockAuthRepository.login(email: email, password: password),
        ).thenAnswer((_) async => const Right(loginResponse));
        when(
          () => mockCacheRepository.saveToken(cache: any(named: 'cache')),
        ).thenAnswer((_) async => false);

        container.listen(
          loginProvider,
          authListener.call,
          fireImmediately: true,
        );

        // Act
        await container
            .read(loginProvider.notifier)
            .login(email: email, password: password);

        // Assert
        verifyInOrder([
          () => authListener(null, const AuthState.initial()),
          () => authListener(
            const AuthState.initial(),
            const AuthState.loading(),
          ),
          () => authListener(
            const AuthState.loading(),
            AuthState.failure(CacheFailureException()),
          ),
        ]);
        verify(
          () => mockAuthRepository.login(email: email, password: password),
        ).called(1);
        verify(
          () => mockCacheRepository.saveToken(cache: any(named: 'cache')),
        ).called(1);
      },
    );
  });

  group('RegisterNotifier', () {
    const email = 'test@example.com';
    const password = 'password';
    const name = 'User Name';
    const commonResponse = DefaultResponse(error: false, message: 'success');

    test('initial state is AuthState.initial', () {
      final state = container.read(registerProvider);
      expect(state, const AuthState.initial());
    });

    test('register success updates state to loaded', () async {
      // Arrange
      when(
        () => mockAuthRepository.register(
          email: email,
          password: password,
          name: name,
        ),
      ).thenAnswer((_) async => const Right(commonResponse));

      container.listen(
        registerProvider,
        authListener.call,
        fireImmediately: true,
      );

      // Act
      await container
          .read(registerProvider.notifier)
          .register(email: email, password: password, name: name);

      // Assert
      verifyInOrder([
        () => authListener(null, const AuthState.initial()),
        () =>
            authListener(const AuthState.initial(), const AuthState.loading()),
        () => authListener(const AuthState.loading(), const AuthState.loaded()),
      ]);
      verify(
        () => mockAuthRepository.register(
          email: email,
          password: password,
          name: name,
        ),
      ).called(1);
    });

    test('register failure updates state to failure', () async {
      // Arrange
      final exception = AppException(
        message: 'Register failed',
        statusCode: 1,
        identifier: 'register',
      );
      when(
        () => mockAuthRepository.register(
          email: email,
          password: password,
          name: name,
        ),
      ).thenAnswer((_) async => Left(exception));

      container.listen(
        registerProvider,
        authListener.call,
        fireImmediately: true,
      );

      // Act
      await container
          .read(registerProvider.notifier)
          .register(email: email, password: password, name: name);

      // Assert
      verifyInOrder([
        () => authListener(null, const AuthState.initial()),
        () =>
            authListener(const AuthState.initial(), const AuthState.loading()),
        () => authListener(
          const AuthState.loading(),
          AuthState.failure(exception),
        ),
      ]);
      verify(
        () => mockAuthRepository.register(
          email: email,
          password: password,
          name: name,
        ),
      ).called(1);
    });
  });

  group('LogoutProvider', () {
    test('logout success returns true', () async {
      // Arrange
      when(
        () => mockCacheRepository.deleteToken(),
      ).thenAnswer((_) async => true);

      // Act
      final result = await container.read(logoutProvider.future);

      // Assert
      expect(result, true);
      verify(() => mockCacheRepository.deleteToken()).called(1);
    });

    test('logout failure returns false', () async {
      // Arrange
      when(
        () => mockCacheRepository.deleteToken(),
      ).thenAnswer((_) async => false);

      // Act
      final result = await container.read(logoutProvider.future);

      // Assert
      expect(result, false);
      verify(() => mockCacheRepository.deleteToken()).called(1);
    });
  });

  group('FetchUserDataProvider', () {
    test('returns username when token exists', () async {
      // Arrange
      const cache = Cache(userId: 'id', userName: 'User Name', token: 'token');
      when(
        () => mockCacheRepository.getToken(),
      ).thenAnswer((_) async => const Right(cache));

      // Act
      final result = await container.read(fetchUserDataProvider.future);

      // Assert
      expect(result, 'User Name');
      verify(() => mockCacheRepository.getToken()).called(1);
    });

    test('returns null when token does not exist', () async {
      // Arrange
      final exception = CacheFailureException();
      when(
        () => mockCacheRepository.getToken(),
      ).thenAnswer((_) async => Left(exception));

      // Act
      final result = await container.read(fetchUserDataProvider.future);

      // Assert
      expect(result, null);
      verify(() => mockCacheRepository.getToken()).called(1);
    });
  });
  group('generated code coverage', () {
    test('LoginProvider overrideWithValue returns Override', () {
      final override = loginProvider.overrideWithValue(
        const AuthState.initial(),
      );
      expect(override, isNotNull);
    });

    test('RegisterProvider overrideWithValue returns Override', () {
      final override = registerProvider.overrideWithValue(
        const AuthState.initial(),
      );
      expect(override, isNotNull);
    });

    test('ObscurePasswordProvider overrideWithValue returns Override', () {
      final override = obscurePasswordProvider.overrideWithValue(true);
      expect(override, isNotNull);
    });
  });
}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockCacheRepository extends Mock implements CacheRepository {}
