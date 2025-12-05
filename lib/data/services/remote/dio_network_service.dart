import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:dicoding_story/data/services/remote/network_service.dart';
import 'package:dicoding_story/domain/models/response.dart' as response;
import 'package:dicoding_story/utils/exception_handler_mixin.dart';
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:dio/dio.dart';

class DioNetworkService extends NetworkService with ExceptionHandlerMixin {
  final Dio dio;

  DioNetworkService(this.dio);

  @override
  Future<Either<AppException, response.Response>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) => handleException(
    () => dio.get(endpoint, queryParameters: queryParameters),
    endpoint: endpoint,
  );

  @override
  Future<Either<AppException, response.Response>> post(
    String endpoint, {
    Object? data,
  }) =>
      handleException(() => dio.post(endpoint, data: data), endpoint: endpoint);
}

class DioImageService extends NetworkImageService {
  final Dio dio;

  DioImageService(this.dio);

  @override
  Future<Uint8List?> get(String url) =>
      dio.get(url).then((value) => value.data);
}
