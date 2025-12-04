import 'package:dartz/dartz.dart';
import 'package:dicoding_story/data/services/remote/auth/model/login_response/login_response.dart';
import 'package:dicoding_story/domain/models/response.dart';
import 'package:equatable/equatable.dart';

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

class CacheFailureException extends Equatable implements AppException {
  @override
  String get identifier => 'CacheFailureException';

  @override
  String get message => 'Unable to save token';

  @override
  int get statusCode => 100;

  @override
  List<Object?> get props => [identifier, message, statusCode];
}

extension HttpExceptionExtension on AppException {
  Left<AppException, Response> toLeft() => Left<AppException, Response>(this);
}

extension LoginExceptionExtension on AppException {
  Left<AppException, LoginResponse> loginToLeft() => Left<AppException, LoginResponse>(this);
} 
