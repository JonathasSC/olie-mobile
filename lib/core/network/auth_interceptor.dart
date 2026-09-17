import 'package:dio/dio.dart';

import 'package:olie/features/auth/data/datasources/auth_local_data_source.dart';

/// Anexa o token JWT salvo (ver [AuthLocalDataSource]) a toda requisição,
/// conforme exigido pela API — ver `references/API.md`.
class AuthInterceptor extends Interceptor {
  final AuthLocalDataSource localDataSource;

  AuthInterceptor(this.localDataSource);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await localDataSource.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
