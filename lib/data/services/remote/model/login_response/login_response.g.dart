// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    _LoginResponse(
      error: json['error'] as bool,
      message: json['message'] as String,
      loginResult: LoginResult.fromJson(
        json['loginResult'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$LoginResponseToJson(_LoginResponse instance) =>
    <String, dynamic>{
      'error': instance.error,
      'message': instance.message,
      'loginResult': instance.loginResult,
    };

_LoginResult _$LoginResultFromJson(Map<String, dynamic> json) => _LoginResult(
  userId: json['userId'] as String,
  name: json['name'] as String,
  token: json['token'] as String,
);

Map<String, dynamic> _$LoginResultToJson(_LoginResult instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'name': instance.name,
      'token': instance.token,
    };
