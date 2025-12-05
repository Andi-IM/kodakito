import 'package:dartz/dartz.dart';
import 'package:dicoding_story/data/services/remote/dio_network_service.dart';
import 'package:dicoding_story/domain/models/response.dart' as response;
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late DioNetworkService dioNetworkService;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    dioNetworkService = DioNetworkService(mockDio);
  });

  group('DioNetworkService', () {
    const tEndpoint = '/test-endpoint';
    const tData = {'key': 'value'};
    final tResponseData = {'message': 'success'};
    final tResponse = Response(
      data: tResponseData,
      statusCode: 200,
      requestOptions: RequestOptions(path: tEndpoint),
    );

    group('get', () {
      test(
        'should return Right(Response) when the call is successful',
        () async {
          // Arrange
          when(
            () => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            ),
          ).thenAnswer((_) async => tResponse);

          // Act
          final result = await dioNetworkService.get(tEndpoint);

          // Assert
          expect(result, isA<Right<AppException, response.Response>>());
          result.fold((l) => fail('Should not return Left'), (r) {
            expect(r.statusCode, 200);
            expect(r.data, tResponseData);
          });
          verify(() => mockDio.get(tEndpoint)).called(1);
        },
      );

      test('should return Left(AppException) when the call fails', () async {
        // Arrange
        final tException = DioException(
          requestOptions: RequestOptions(path: tEndpoint),
          response: Response(
            requestOptions: RequestOptions(path: tEndpoint),
            statusCode: 400,
            statusMessage: 'Bad Request',
            data: {'message': 'Bad Request'},
          ),
          type: DioExceptionType.badResponse,
        );
        when(
          () => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          ),
        ).thenThrow(tException);

        // Act
        final result = await dioNetworkService.get(tEndpoint);

        // Assert
        expect(result, isA<Left<AppException, response.Response>>());
        verify(() => mockDio.get(tEndpoint)).called(1);
      });
    });

    group('post', () {
      test(
        'should return Right(Response) when the call is successful',
        () async {
          // Arrange
          when(
            () => mockDio.post(any(), data: any(named: 'data')),
          ).thenAnswer((_) async => tResponse);

          // Act
          final result = await dioNetworkService.post(tEndpoint, data: tData);

          // Assert
          expect(result, isA<Right<AppException, response.Response>>());
          result.fold((l) => fail('Should not return Left'), (r) {
            expect(r.statusCode, 200);
            expect(r.data, tResponseData);
          });
          verify(() => mockDio.post(tEndpoint, data: tData)).called(1);
        },
      );

      test('should return Left(AppException) when the call fails', () async {
        // Arrange
        final tException = DioException(
          requestOptions: RequestOptions(path: tEndpoint),
          response: Response(
            requestOptions: RequestOptions(path: tEndpoint),
            statusCode: 500,
            statusMessage: 'Internal Server Error',
            data: {'message': 'Internal Server Error'},
          ),
          type: DioExceptionType.badResponse,
        );
        when(
          () => mockDio.post(any(), data: any(named: 'data')),
        ).thenThrow(tException);

        // Act
        final result = await dioNetworkService.post(tEndpoint, data: tData);

        // Assert
        expect(result, isA<Left<AppException, response.Response>>());
        verify(() => mockDio.post(tEndpoint, data: tData)).called(1);
      });
    });
  });
}
