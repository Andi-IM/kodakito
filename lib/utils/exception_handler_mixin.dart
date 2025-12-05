import 'dart:io';
import 'dart:developer';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dicoding_story/data/services/remote/network_service.dart';
import 'package:dartz/dartz.dart';
import 'package:dicoding_story/domain/models/response.dart' as response;
import 'package:dicoding_story/utils/http_exception.dart';

mixin ExceptionHandlerMixin on NetworkService {
  Future<Either<AppException, response.Response>>
  handleException<T extends Object>(
    Future<Response<dynamic>> Function() handler, {
    String endpoint = '',
  }) async {
    try {
      final res = await handler();
      return Right(
        response.Response(
          statusCode: res.statusCode ?? 200,
          data: res.data,
          message: res.statusMessage,
        ),
      );
    } catch (e) {
      String message = '';
      String identifier = '';
      int statusCode = 0;
      log(e.runtimeType.toString());
      switch (e) {
        case SocketException e:
          message = 'Unable to connect to the server.';
          statusCode = 0;
          identifier = 'SocketException ${e.message}\n at $endpoint';
          break;
        case DioException e:
          message = e.response?.data['message'] ?? 'Internal Error occurred';
          statusCode = 1;
          identifier = 'DioException ${e.message}\n at $endpoint';
          break;
        default:
          message = 'Something went wrong';
          statusCode = 2;
          identifier = 'UnknownException ${e.toString()}\n at $endpoint';
      }
      return Left(
        AppException(
          message: message,
          identifier: identifier,
          statusCode: statusCode,
        ),
      );
    }
  }
}
