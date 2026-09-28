import 'package:olie/features/whatsapp/domain/entities/whatsapp_connection.dart';
import 'package:olie/features/whatsapp/domain/repositories/whatsapp_repository.dart';

/// Não implementa [UseCase] pois expõe um [Stream] contínuo.
class WatchWhatsAppConnection {
  final WhatsAppRepository repository;

  WatchWhatsAppConnection(this.repository);

  Stream<WhatsAppConnection> call() => repository.watchConnection();
}
