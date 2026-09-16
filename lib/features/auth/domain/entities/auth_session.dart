import 'package:equatable/equatable.dart';

class AuthSession extends Equatable {
  final String token;
  final String tokenType;

  const AuthSession({required this.token, required this.tokenType});

  @override
  List<Object?> get props => [token, tokenType];
}
