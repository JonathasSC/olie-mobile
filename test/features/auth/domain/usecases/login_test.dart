import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:olie/features/auth/domain/entities/auth_session.dart';
import 'package:olie/features/auth/domain/repositories/auth_repository.dart';
import 'package:olie/features/auth/domain/usecases/login.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late Login usecase;

  setUp(() {
    repository = MockAuthRepository();
    usecase = Login(repository);
  });

  const session = AuthSession(token: 'jwt-token', tokenType: 'Bearer');
  const params = LoginParams(email: 'jonathas@example.com', password: 'senha123');

  test('deve retornar uma AuthSession quando o login é bem-sucedido', () async {
    when(
      () => repository.login(
        email: params.email,
        password: params.password,
      ),
    ).thenAnswer((_) async => const Right(session));

    final result = await usecase(params);

    expect(result, const Right(session));
    verify(
      () => repository.login(email: params.email, password: params.password),
    ).called(1);
    verifyNoMoreInteractions(repository);
  });
}
