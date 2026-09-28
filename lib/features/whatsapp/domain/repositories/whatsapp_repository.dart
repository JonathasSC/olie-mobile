import 'package:dartz/dartz.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/features/whatsapp/domain/entities/whatsapp_connection.dart';

abstract class WhatsAppRepository {
  Future<Either<Failure, WhatsAppConnection>> getConnection();

  Future<Either<Failure, WhatsAppConnection>> connect();

  Future<Either<Failure, WhatsAppConnection>> disconnect();

  /// Mudanças da conexão em tempo real (inclui cada QR code novo).
  Stream<WhatsAppConnection> watchConnection();
}
