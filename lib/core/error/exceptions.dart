class ServerException implements Exception {
  final String message;

  /// Código estável do erro de negócio (ex.: `DUPLICATE_PHONE`), quando a API
  /// devolve o corpo `{code, message, details}` — ver `references/API.md`.
  final String? code;

  /// Dados extras do erro (ex.: lista de problemas de um arquivo importado).
  final Object? details;

  const ServerException([
    this.message = 'Erro ao comunicar com o servidor.',
    this.code,
    this.details,
  ]);
}

class CacheException implements Exception {
  final String message;

  const CacheException([this.message = 'Erro ao acessar dados locais.']);
}

class NetworkException implements Exception {
  final String message;

  const NetworkException([this.message = 'Sem conexão com a internet.']);
}
