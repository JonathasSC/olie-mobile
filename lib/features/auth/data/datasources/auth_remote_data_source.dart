import 'package:dio/dio.dart';

import 'package:olie/core/error/exceptions.dart';
import 'package:olie/features/auth/data/models/auth_session_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  });

  Future<AuthSessionModel> register({
    required String name,
    required String email,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return AuthSessionModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioException(e, fallback: 'E-mail ou senha inválidos.');
    }
  }

  @override
  Future<AuthSessionModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );
      return AuthSessionModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioException(e, fallback: 'Não foi possível criar a conta.');
    }
  }

  Exception _mapDioException(DioException e, {required String fallback}) {
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const NetworkException();
      default:
        final data = e.response?.data;
        final message = data is Map<String, dynamic>
            ? data['message'] as String?
            : null;
        return ServerException(message ?? fallback);
    }
  }
}
