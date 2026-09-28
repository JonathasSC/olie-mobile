import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import 'package:olie/core/error/exceptions.dart';
import 'package:olie/core/error/failures.dart';
import 'package:olie/features/inquiries/data/datasources/inquiry_realtime_data_source.dart';
import 'package:olie/features/inquiries/data/datasources/inquiry_remote_data_source.dart';
import 'package:olie/features/inquiries/data/models/inquiry_support_model.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry_event.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry_support.dart';
import 'package:olie/features/inquiries/domain/repositories/inquiry_repository.dart';

class InquiryRepositoryImpl implements InquiryRepository {
  final InquiryRemoteDataSource remoteDataSource;
  final InquiryRealtimeDataSource realtimeDataSource;

  /// Fotos nunca mudam depois de enviadas: guardadas na memória da sessão.
  final Map<String, Uint8List> _photoCache = {};

  InquiryRepositoryImpl({
    required this.remoteDataSource,
    required this.realtimeDataSource,
  });

  @override
  Future<Either<Failure, InquirySettings>> getSettings() =>
      _request(remoteDataSource.getSettings);

  @override
  Future<Either<Failure, InquiryPreview>> preview(
    List<InquiryItemDraft> items,
  ) => _request(() => remoteDataSource.preview(items));

  @override
  Future<Either<Failure, Inquiry>> createInquiry({
    required Set<String> categoryIds,
    required List<String> contactIds,
    required List<InquiryItemDraft> items,
    required bool simulate,
    required bool confirmDuplicates,
  }) async {
    try {
      return Right(
        await remoteDataSource.createInquiry(
          categoryIds: categoryIds,
          contactIds: contactIds,
          items: items,
          simulate: simulate,
          confirmDuplicates: confirmDuplicates,
        ),
      );
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      if (e.code == 'DUPLICATE_INQUIRY') {
        return Left(
          DuplicateInquiryFailure(
            e.message,
            InquirySupportModel.warningsFromJson(e.details),
          ),
        );
      }
      return Left(ServerFailure(e.message, e.code));
    }
  }

  @override
  Future<Either<Failure, List<Inquiry>>> getInquiries(InquiryFilter filter) =>
      _request(() => remoteDataSource.getInquiries(filter));

  @override
  Future<Either<Failure, Inquiry>> getInquiry(String id) =>
      _request(() => remoteDataSource.getInquiry(id));

  @override
  Future<Either<Failure, InquiryDraft>> getDraft(String id) =>
      _request(() => remoteDataSource.getDraft(id));

  @override
  Future<Either<Failure, Inquiry>> pause(String id) =>
      _request(() => remoteDataSource.control(id, 'pause'));

  @override
  Future<Either<Failure, Inquiry>> resume(String id) =>
      _request(() => remoteDataSource.control(id, 'resume'));

  @override
  Future<Either<Failure, Inquiry>> cancel(String id) =>
      _request(() => remoteDataSource.control(id, 'cancel'));

  @override
  Future<Either<Failure, Inquiry>> resendFailed(String id) =>
      _request(() => remoteDataSource.control(id, 'resend-failed'));

  @override
  Future<Either<Failure, InquiryPhoto>> uploadPhoto({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final result = await _request(
      () => remoteDataSource.uploadPhoto(bytes, fileName),
    );
    // O backend pode ter reduzido a imagem, mas para a miniatura local o
    // original serve e evita baixar de novo.
    result.fold((_) {}, (photo) => _photoCache[photo.id] = bytes);
    return result;
  }

  @override
  Future<Either<Failure, Uint8List>> getPhoto(String id) async {
    final cached = _photoCache[id];
    if (cached != null) return Right(cached);
    final result = await _request(() => remoteDataSource.getPhoto(id));
    result.fold((_) {}, (bytes) => _photoCache[id] = bytes);
    return result;
  }

  @override
  Stream<InquiryEvent> watchEvents() => realtimeDataSource.stream;

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
