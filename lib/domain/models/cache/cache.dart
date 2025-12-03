import 'package:equatable/equatable.dart';

class Cache extends Equatable {
  final String token;
  final String userName;
  final String userId;

  const Cache({
    required this.token,
    required this.userName,
    required this.userId,
  });

  factory Cache.fromJson(Map<String, dynamic> json) => Cache(
    token: json['token'],
    userName: json['userName'],
    userId: json['userId'],
  );

  Map<String, dynamic> toJson() => {
    'token': token,
    'userName': userName,
    'userId': userId,
  };

  Cache copyWith({String? token, String? userName, String? userId}) {
    return Cache(
      token: token ?? this.token,
      userName: userName ?? this.userName,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() =>
      'Cache(token: $token, userName: $userName, userId: $userId)';

  @override
  List<Object?> get props => [token, userName, userId];
}
