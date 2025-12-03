import 'package:dicoding_story/domain/models/cache/cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Cache', () {
    const tCache = Cache(
      token: 'token',
      userName: 'userName',
      userId: 'userId',
    );

    test('should return a valid model from JSON', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'token': 'token',
        'userName': 'userName',
        'userId': 'userId',
      };

      // Act
      final result = Cache.fromJson(jsonMap);

      // Assert
      expect(result, tCache);
    });

    test('should return a JSON map containing proper data', () {
      // Act
      final result = tCache.toJson();

      // Assert
      final expectedMap = {
        'token': 'token',
        'userName': 'userName',
        'userId': 'userId',
      };
      expect(result, expectedMap);
    });

    test('should return a copy with updated fields', () {
      // Act
      final result = tCache.copyWith(token: 'newToken');

      // Assert
      expect(result.token, 'newToken');
      expect(result.userName, tCache.userName);
      expect(result.userId, tCache.userId);
    });

    test('should return a copy with same fields if null is passed', () {
      // Act
      final result = tCache.copyWith();

      // Assert
      expect(result, tCache);
    });

    test('props should contain all fields', () {
      expect(tCache.props, ['token', 'userName', 'userId']);
    });

    test('toString should return correct string representation', () {
      expect(
        tCache.toString(),
        'Cache(token: token, userName: userName, userId: userId)',
      );
    });
  });
}
