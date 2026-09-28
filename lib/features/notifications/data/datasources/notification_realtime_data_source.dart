import 'package:olie/core/network/realtime_client.dart';
import 'package:olie/features/notifications/data/models/app_notification_model.dart';

abstract class NotificationRealtimeDataSource {
  Stream<AppNotificationModel> get stream;

  Future<void> connect();

  Future<void> disconnect();
}

class NotificationRealtimeDataSourceImpl
    implements NotificationRealtimeDataSource {
  static const _destination = '/user/queue/notifications';

  final RealtimeClient realtimeClient;

  NotificationRealtimeDataSourceImpl(this.realtimeClient);

  @override
  Stream<AppNotificationModel> get stream => realtimeClient
      .subscribe(_destination)
      .map(AppNotificationModel.fromJson);

  @override
  Future<void> connect() => realtimeClient.connect();

  @override
  Future<void> disconnect() => realtimeClient.disconnect();
}
