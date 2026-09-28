import 'package:olie/core/network/realtime_client.dart';
import 'package:olie/features/whatsapp/data/models/whatsapp_connection_model.dart';

abstract class WhatsAppRealtimeDataSource {
  Stream<WhatsAppConnectionModel> get stream;
}

class WhatsAppRealtimeDataSourceImpl implements WhatsAppRealtimeDataSource {
  static const _destination = '/user/queue/whatsapp';

  final RealtimeClient realtimeClient;

  WhatsAppRealtimeDataSourceImpl(this.realtimeClient);

  @override
  Stream<WhatsAppConnectionModel> get stream => realtimeClient
      .subscribe(_destination)
      .map(WhatsAppConnectionModel.fromJson);
}
