import 'package:dicoding_story/data/services/api/remote/auth/model/login_request/login_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginRequest', () {
    test('toJson should return a valid map', () {
      // Arrange
      const model = LoginRequest(
        email: 'test@example.com',
        password: 'password',
      );

      // Act
      final result = model.toJson();

      // Assert
      expect(result['email'], 'test@example.com');
      expect(result['password'], 'password');
    });
  });
}
