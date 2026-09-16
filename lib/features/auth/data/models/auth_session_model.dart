import 'package:olie/features/auth/domain/entities/auth_session.dart';

class AuthSessionModel extends AuthSession {
  const AuthSessionModel({required super.token, required super.tokenType});

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      token: json['token'] as String,
      tokenType: json['tokenType'] as String? ?? 'Bearer',
    );
  }
}
