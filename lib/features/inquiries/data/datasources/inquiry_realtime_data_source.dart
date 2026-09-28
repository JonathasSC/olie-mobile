import 'package:olie/core/network/realtime_client.dart';
import 'package:olie/features/inquiries/data/models/inquiry_model.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry_event.dart';

abstract class InquiryRealtimeDataSource {
  Stream<InquiryEvent> get stream;
}

class InquiryRealtimeDataSourceImpl implements InquiryRealtimeDataSource {
  static const _destination = '/user/queue/inquiries';

  final RealtimeClient realtimeClient;

  InquiryRealtimeDataSourceImpl(this.realtimeClient);

  @override
  Stream<InquiryEvent> get stream => realtimeClient
      .subscribe(_destination)
      .map(InquiryModel.eventFromJson);
}
