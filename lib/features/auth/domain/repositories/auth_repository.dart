import 'package:dartz/dartz.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/features/auth/domain/entities/auth_session.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthSession>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthSession>> register({
    required String name,
    required String email,
    required String password,
  });
}
