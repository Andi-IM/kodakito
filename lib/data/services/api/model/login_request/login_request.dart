import 'dart:convert' show json;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_request.g.dart';
part 'login_request.freezed.dart';

String loginRequestToJson(LoginRequest instance) =>
    json.encode(instance.toJson());

@freezed
abstract class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    /// Email address.
    required String email,

    /// Plain text password.
    required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, Object?> json) =>
      _$LoginRequestFromJson(json);
}
