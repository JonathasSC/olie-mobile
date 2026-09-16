import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/features/auth/domain/entities/auth_session.dart';
import 'package:olie/features/auth/domain/usecases/login.dart';
import 'package:olie/features/auth/domain/usecases/register.dart';
import 'package:olie/features/auth/presentation/bloc/auth_bloc.dart';

class MockLogin extends Mock implements Login {}

class MockRegister extends Mock implements Register {}

void main() {
  late MockLogin login;
  late MockRegister register;

  setUpAll(() {
    registerFallbackValue(
      const LoginParams(email: 'fallback@example.com', password: 'fallback'),
    );
    registerFallbackValue(
      const RegisterParams(
        name: 'fallback',
        email: 'fallback@example.com',
        password: 'fallback',
      ),
    );
  });

  setUp(() {
    login = MockLogin();
    register = MockRegister();
  });

  AuthBloc buildBloc() => AuthBloc(login: login, register: register);

  const session = AuthSession(token: 'jwt-token', tokenType: 'Bearer');
  const loginEvent = LoginSubmitted(
    email: 'jonathas@example.com',
    password: 'senha123',
  );

  blocTest<AuthBloc, AuthState>(
    'emite [loading, success] quando o login funciona',
    build: () {
      when(() => login(any())).thenAnswer((_) async => const Right(session));
      return buildBloc();
    },
    act: (bloc) => bloc.add(loginEvent),
    expect: () => [
      const AuthState(status: AuthStatus.loading),
      const AuthState(status: AuthStatus.success, session: session),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emite [loading, failure] quando o login falha',
    build: () {
      when(() => login(any())).thenAnswer(
        (_) async => const Left(ServerFailure('Credenciais inválidas.')),
      );
      return buildBloc();
    },
    act: (bloc) => bloc.add(loginEvent),
    expect: () => [
      const AuthState(status: AuthStatus.loading),
      const AuthState(
        status: AuthStatus.failure,
        errorMessage: 'Credenciais inválidas.',
      ),
    ],
  );
}
