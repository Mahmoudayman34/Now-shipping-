import 'user_model.dart';

class AuthResponse {
  final String status;
  final String token;
  final User user;

  AuthResponse({
    required this.status,
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      status: json['status'] as String,
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'token': token,
      'user': user.toJson(),
    };
  }
}