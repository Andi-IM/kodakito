import 'package:dicoding_story/data/services/api/remote/auth/model/default_response/default_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DefaultResponse', () {
    test('fromJson should return a valid model', () {
      // Arrange
      final json = {'error': false, 'message': 'success'};

      // Act
      final result = DefaultResponse.fromJson(json);

      // Assert
      expect(result.error, false);
      expect(result.message, 'success');
    });

    test('toJson should return a valid map', () {
      // Arrange
      const model = DefaultResponse(error: false, message: 'success');
      final expectedJson = {'error': false, 'message': 'success'};

      // Act
      final result = model.toJson();

      // Assert
      expect(result, expectedJson);
    });
  });
}
