class AppConstants {
  AppConstants._();

  static const String appName = 'Olie';

  /// Prefixo `/api/v1` já incluído — veja `reference/API.md`.
  ///
  /// `localhost` funciona para Web e simulador iOS. No emulador Android,
  /// troque para `http://10.0.2.2:8090/api/v1`; em dispositivo físico, use
  /// o IP da máquina rodando a API na mesma rede.
  static const String baseUrl = 'http://localhost:8090/api/v1';
}
