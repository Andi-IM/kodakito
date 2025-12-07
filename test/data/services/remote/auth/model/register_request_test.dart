import 'package:dicoding_story/data/services/remote/auth/model/register_request/register_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RegisterRequest', () {
    test('toJson should return a valid map', () {
      // Arrange
      const model = RegisterRequest(
        name: 'User Name',
        email: 'test@example.com',
        password: 'password',
      );

      // Act
      final result = model.toJson();

      // Assert
      expect(result['name'], 'User Name');
      expect(result['email'], 'test@example.com');
      expect(result['password'], 'password');
    });
  });
}
