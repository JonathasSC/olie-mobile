import 'package:dartz/dartz.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/whatsapp/domain/entities/whatsapp_connection.dart';
import 'package:olie/features/whatsapp/domain/repositories/whatsapp_repository.dart';

class GetWhatsAppConnection implements UseCase<WhatsAppConnection, NoParams> {
  final WhatsAppRepository repository;

  GetWhatsAppConnection(this.repository);

  @override
  Future<Either<Failure, WhatsAppConnection>> call(NoParams params) {
    return repository.getConnection();
  }
}
