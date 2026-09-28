import 'package:dartz/dartz.dart';

import 'package:olie/core/error/exceptions.dart';
import 'package:olie/core/error/failures.dart';
import 'package:olie/features/whatsapp/data/datasources/whatsapp_realtime_data_source.dart';
import 'package:olie/features/whatsapp/data/datasources/whatsapp_remote_data_source.dart';
import 'package:olie/features/whatsapp/domain/entities/whatsapp_connection.dart';
import 'package:olie/features/whatsapp/domain/repositories/whatsapp_repository.dart';

class WhatsAppRepositoryImpl implements WhatsAppRepository {
  final WhatsAppRemoteDataSource remoteDataSource;
  final WhatsAppRealtimeDataSource realtimeDataSource;

  WhatsAppRepositoryImpl({
    required this.remoteDataSource,
    required this.realtimeDataSource,
  });

  @override
  Future<Either<Failure, WhatsAppConnection>> getConnection() =>
      _request(remoteDataSource.getConnection);

  @override
  Future<Either<Failure, WhatsAppConnection>> connect() =>
      _request(remoteDataSource.connect);

  @override
  Future<Either<Failure, WhatsAppConnection>> disconnect() =>
      _request(remoteDataSource.disconnect);

  @override
  Stream<WhatsAppConnection> watchConnection() => realtimeDataSource.stream;

  Future<Either<Failure, T>> _request<T>(Future<T> Function() request) async {
    try {
      return Right(await request());
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.code));
    }
  }
}
