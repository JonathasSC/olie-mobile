import 'dart:async';
import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';

import 'package:olie/core/constants/app_constants.dart';
import 'package:olie/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:olie/features/notifications/data/models/app_notification_model.dart';

abstract class NotificationRealtimeDataSource {
  Stream<AppNotificationModel> get stream;

  Future<void> connect();

  Future<void> disconnect();
}

class NotificationRealtimeDataSourceImpl
    implements NotificationRealtimeDataSource {
  static const _destination = '/user/queue/notifications';

  final AuthLocalDataSource authLocalDataSource;

  final _controller = StreamController<AppNotificationModel>.broadcast();
  StompClient? _client;
  bool _isConnecting = false;

  NotificationRealtimeDataSourceImpl(this.authLocalDataSource);

  @override
  Stream<AppNotificationModel> get stream => _controller.stream;

  @override
  Future<void> connect() async {
    if (_isConnecting || (_client?.connected ?? false)) return;

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
    _client?.subscribe(
      destination: _destination,
      callback: (frame) {
        final body = frame.body;
        if (body == null) return;
        final json = jsonDecode(body) as Map<String, dynamic>;
        _controller.add(AppNotificationModel.fromJson(json));
      },
    );
  }

  @override
  Future<void> disconnect() async {
    _client?.deactivate();
    _client = null;
    _isConnecting = false;
  }
}
