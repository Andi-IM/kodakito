import 'dart:convert' show json;

import 'package:equatable/equatable.dart';

String loginRequestToJson(LoginRequest instance) =>
    json.encode(instance.toJson());

class LoginRequest extends Equatable {
  const LoginRequest({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  Map<String, dynamic> toJson() => {'email': email, 'password': password};

  @override
  List<Object?> get props => [email, password];
}
