import 'package:dartz/dartz.dart';
import 'package:dicoding_story/common/globals.dart';
import 'package:dicoding_story/data/services/remote/network_service.dart';
import 'package:dicoding_story/domain/models/response.dart' as response;
import 'package:dicoding_story/env/env.dart';
import 'package:dicoding_story/utils/exception_handler_mixin.dart';
import 'package:dicoding_story/utils/http_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioNetworkService extends NetworkService with ExceptionHandlerMixin {
  final Dio dio;

  DioNetworkService(this.dio) {
    if (!kTestMode) {
      dio.options = dioBaseOptions;
      if (kDebugMode) {
        dio.interceptors.add(
          LogInterceptor(requestBody: true, responseBody: true),
        );
      }
    }
  }

  BaseOptions get dioBaseOptions =>
      BaseOptions(baseUrl: baseUrl, headers: headers);

  @override
  String get baseUrl => Env.storyUrl;

  @override
  Map<String, Object> get headers => {
    'accept': 'application/json',
    'Content-Type': 'application/json',
  };

  @override
  Map<String, dynamic>? updateHeader(Map<String, dynamic> data) {
    final header = {...data, ...headers};
    if (!kTestMode) {
      dio.options.headers = header;
    }
    return header;
  }

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
