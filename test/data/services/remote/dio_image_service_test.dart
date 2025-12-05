import 'dart:typed_data' show Uint8List;

import 'package:dicoding_story/data/services/remote/dio_network_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late DioImageService dioImageService;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dioImageService = DioImageService(mockDio);
  });

  group('DioImageService', () {
    const tUrl = 'https://example.com/image.png';
    final tBytes = Uint8List.fromList([1, 2, 3]);

    test('get should return Uint8List when the call is successful', () async {
      // Arrange
      when(() => mockDio.get(tUrl)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: tUrl),
          data: tBytes,
          statusCode: 200,
        ),
      );

      // Act
      final result = await dioImageService.get(tUrl);

      // Assert
      expect(result, tBytes);
      verify(() => mockDio.get(tUrl)).called(1);
    });

    test('get should throw exception when the call fails', () async {
      // Arrange
      final tException = DioException(
        requestOptions: RequestOptions(path: tUrl),
        error: 'Error',
      );
      when(() => mockDio.get(tUrl)).thenThrow(tException);

      // Act & Assert
      expect(() => dioImageService.get(tUrl), throwsA(equals(tException)));
      verify(() => mockDio.get(tUrl)).called(1);
    });
  });
}
