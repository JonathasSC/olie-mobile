class AppConstants {
  AppConstants._();

  static const String appName = 'Olie';

  /// Prefixo `/api/v1` já incluído — veja `reference/API.md`.
  ///
  /// `localhost` funciona para Web e simulador iOS. No emulador Android,
  /// troque para `http://10.0.2.2:8090/api/v1`; em dispositivo físico, use
  /// o IP da máquina rodando a API na mesma rede.
  static const String baseUrl = 'http://localhost:8090/api/v1';

  /// Handshake do WebSocket de notificações (`/ws/notifications`), derivado
  /// de [baseUrl] — mesmo host/porta, sem o prefixo `/api/v1`.
  static String notificationsWebSocketUrl(String token) {
    final uri = Uri.parse(baseUrl);
    final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
    return '$scheme://${uri.authority}/ws/notifications?token=$token';
  }
}
