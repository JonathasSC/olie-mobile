import 'dart:async';
import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';

import 'package:olie/core/constants/app_constants.dart';
import 'package:olie/features/auth/data/datasources/auth_local_data_source.dart';

/// Conexão STOMP única da sessão, compartilhada por todas as features que
/// recebem eventos em tempo real (notificações, WhatsApp, consultas).
///
/// Cada destino vira um [Stream] próprio; as assinaturas são refeitas a cada
/// (re)conexão, então quem escuta não precisa saber se a conexão caiu.
class RealtimeClient {
  final AuthLocalDataSource authLocalDataSource;

  final Map<String, StreamController<Map<String, dynamic>>> _channels = {};
  StompClient? _client;
  bool _isConnecting = false;

  RealtimeClient(this.authLocalDataSource);

  bool get isConnected => _client?.connected ?? false;

  /// Eventos JSON publicados em [destination] (ex.: `/user/queue/whatsapp`).
  /// Também dispara a conexão, caso ainda não exista.
  Stream<Map<String, dynamic>> subscribe(String destination) {
    final isNew = !_channels.containsKey(destination);
    final controller = _channels.putIfAbsent(
      destination,
      StreamController<Map<String, dynamic>>.broadcast,
    );
    if (isNew && isConnected) _subscribe(destination);
    unawaited(connect());
    return controller.stream;
  }

  Future<void> connect() async {
    if (_isConnecting || isConnected) return;

    final token = await authLocalDataSource.getToken();
    if (token == null) return;

    _isConnecting = true;
    _client = StompClient(
      config: StompConfig(
        url: AppConstants.notificationsWebSocketUrl(token),
        onConnect: _onConnect,
        onWebSocketError: (dynamic error) => _isConnecting = false,
        onStompError: (frame) => _isConnecting = false,
        onDisconnect: (frame) => _isConnecting = false,
      ),
    );
    _client!.activate();
  }

  void _onConnect(StompFrame connectFrame) {
    _isConnecting = false;
    _channels.keys.forEach(_subscribe);
  }

  void _subscribe(String destination) {
    _client?.subscribe(
      destination: destination,
      callback: (frame) {
        final body = frame.body;
        if (body == null) return;
        _channels[destination]?.add(jsonDecode(body) as Map<String, dynamic>);
      },
    );
  }

  Future<void> disconnect() async {
    _client?.deactivate();
    _client = null;
    _isConnecting = false;
  }
}
