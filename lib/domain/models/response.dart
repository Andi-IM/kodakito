import 'package:dartz/dartz.dart';
import 'package:dicoding_story/utils/http_exception.dart';

class Response {
  final int statusCode;
  final String? message;
  final dynamic data;

  Response({required this.statusCode, this.message, this.data = const {}});
}

extension ResponseExtension on Response {
  Right<AppException, Response> get toRight => Right(this);
}
