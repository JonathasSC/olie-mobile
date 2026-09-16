class ServerException implements Exception {
  final String message;

  const ServerException([this.message = 'Erro ao comunicar com o servidor.']);
}

class CacheException implements Exception {
  final String message;

  const CacheException([this.message = 'Erro ao acessar dados locais.']);
}

class NetworkException implements Exception {
  final String message;

  const NetworkException([this.message = 'Sem conexão com a internet.']);
}
