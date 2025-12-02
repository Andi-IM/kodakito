import 'package:dartz/dartz.dart';
import 'package:dicoding_story/domain/models/response.dart';

class AppException implements Exception {
  final String message;
  final int statusCode;
  final String identifier;

  AppException({
    required this.message,
    required this.statusCode,
    required this.identifier,
  });

  @override
  String toString() {
    return 'AppException(message: $message, statusCode: $statusCode, identifier: $identifier)';
  }
}

extension HttpExceptionExtension on AppException {
  Left<AppException, Response> toLeft() {
    return Left(this);
  }
}
