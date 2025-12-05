import 'package:dartz/dartz.dart';
import 'package:dicoding_story/domain/models/response.dart';
import 'package:dicoding_story/utils/http_exception.dart';

abstract class NetworkService {
  Future<Either<AppException, Response>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  });

  Future<Either<AppException, Response>> post(String endpoint, {Object? data});
}
