import 'package:dartz/dartz.dart';

import 'package:olie/core/error/exceptions.dart';
import 'package:olie/core/error/failures.dart';
import 'package:olie/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:olie/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:olie/features/auth/domain/entities/auth_session.dart';
import 'package:olie/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, AuthSession>> login({
    required String email,
    required String password,
  }) {
    return _authenticate(
      () => remoteDataSource.login(email: email, password: password),
    );
  }

  @override
  Future<Either<Failure, AuthSession>> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _authenticate(
      () => remoteDataSource.register(
        name: name,
        email: email,
        password: password,
      ),
    );
  }

  Future<Either<Failure, AuthSession>> _authenticate(
    Future<AuthSession> Function() request,
  ) async {
    try {
      final session = await request();
      await localDataSource.cacheToken(session.token);
      return Right(session);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
