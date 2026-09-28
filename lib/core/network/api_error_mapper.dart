import 'package:dio/dio.dart';

import 'package:olie/core/error/exceptions.dart';

/// Converte um erro do Dio na exceção da camada de dados: falha de rede vira
/// [NetworkException]; resposta de erro vira [ServerException], levando a
/// `message` em português, o `code` e os `details` quando a API os envia.
Exception mapDioException(DioException e, {required String fallback}) {
  switch (e.type) {
    case DioExceptionType.connectionError:
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return const NetworkException();
    default:
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        return ServerException(
          data['message'] as String? ?? fallback,
          data['code'] as String?,
          data['details'],
        );
      }
      return ServerException(fallback);
  }
}
