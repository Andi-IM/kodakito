import 'package:dicoding_story/data/repositories/auth/auth_repository_dev.dart';
import 'package:dicoding_story/data/services/api/remote/auth/model/default_response/default_response.dart';
import 'package:dicoding_story/data/services/api/remote/auth/model/login_response/login_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AuthRepositoryDev authRepository;

  setUp(() {
    authRepository = AuthRepositoryDev();
  });

  group('AuthRepositoryDev', () {
    test('login returns Right(LoginResponse) with correct data', () async {
      // Act
      final result = await authRepository.login(
        email: 'test@example.com',
        password: 'password',
      );

      // Assert
      expect(result.isRight(), true);
      result.fold((l) => fail('Should not return Left'), (r) {
        expect(r, isA<LoginResponse>());
        expect(r.error, false);
        expect(r.message, 'success');
        expect(r.loginResult, isA<LoginResult>());
        expect(r.loginResult.userId, 'user-asdf');
        expect(r.loginResult.name, 'Andi Irham');
        expect(r.loginResult.token, 'token');
      });
    });

    test('register returns Right(DefaultResponse) with no error', () async {
      // Act
      final result = await authRepository.register(
        name: 'Test User',
        email: 'test@example.com',
        password: 'password',
      );

      // Assert
      expect(result.isRight(), true);
      result.fold((l) => fail('Should not return Left'), (r) {
        expect(r, isA<DefaultResponse>());
        expect(r.error, false);
      });
    });
  });
}
