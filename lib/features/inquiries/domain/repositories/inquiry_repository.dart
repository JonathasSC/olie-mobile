import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry_event.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry_support.dart';

abstract class InquiryRepository {
  Future<Either<Failure, InquirySettings>> getSettings();

  Future<Either<Failure, InquiryPreview>> preview(List<InquiryItemDraft> items);

  Future<Either<Failure, Inquiry>> createInquiry({
    required Set<String> categoryIds,
    required List<String> contactIds,
    required List<InquiryItemDraft> items,
    required bool simulate,
    required bool confirmDuplicates,
  });

  Future<Either<Failure, List<Inquiry>>> getInquiries(InquiryFilter filter);

  Future<Either<Failure, Inquiry>> getInquiry(String id);

  Future<Either<Failure, InquiryDraft>> getDraft(String id);

  Future<Either<Failure, Inquiry>> pause(String id);

  Future<Either<Failure, Inquiry>> resume(String id);

  Future<Either<Failure, Inquiry>> cancel(String id);

  Future<Either<Failure, Inquiry>> resendFailed(String id);

  Future<Either<Failure, InquiryPhoto>> uploadPhoto({
    required Uint8List bytes,
    required String fileName,
  });

  Future<Either<Failure, Uint8List>> getPhoto(String id);

  Stream<InquiryEvent> watchEvents();
}
