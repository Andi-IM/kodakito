import 'dart:convert';
import 'package:dicoding_story/data/services/api/remote/auth/model/login_response/login_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginResponse', () {
    test('fromJson should return a valid model', () {
      // Arrange
      final json = {
        'error': false,
        'message': 'success',
        'loginResult': {
          'userId': 'user-id',
          'name': 'User Name',
          'token': 'token',
        },
      };

      // Act
      final result = LoginResponse.fromJson(json);

      // Assert
      expect(result.error, false);
      expect(result.message, 'success');
      expect(result.loginResult.userId, 'user-id');
      expect(result.loginResult.name, 'User Name');
      expect(result.loginResult.token, 'token');
    });

    test('toJson should return a valid map', () {
      // Arrange
      const model = LoginResponse(
        error: false,
        message: 'success',
        loginResult: LoginResult(
          userId: 'user-id',
          name: 'User Name',
          token: 'token',
        ),
      );
      final expectedJson = {
        'error': false,
        'message': 'success',
        'loginResult': {
          'userId': 'user-id',
          'name': 'User Name',
          'token': 'token',
        },
      };

      // Act
      final result = model.toJson();
      final jsonString = json.encode(result);
      final decoded = json.decode(jsonString);

      // Assert
      expect(decoded, expectedJson);
    });
  });
}
