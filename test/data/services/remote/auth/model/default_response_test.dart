import 'package:dicoding_story/data/services/remote/auth/model/default_response/default_response.dart';
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
  });
}
