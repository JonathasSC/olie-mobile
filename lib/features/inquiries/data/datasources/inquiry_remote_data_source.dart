import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'package:olie/core/network/api_error_mapper.dart';
import 'package:olie/features/inquiries/data/models/inquiry_model.dart';
import 'package:olie/features/inquiries/data/models/inquiry_support_model.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry_support.dart';

abstract class InquiryRemoteDataSource {
  Future<InquirySettings> getSettings();

  Future<InquiryPreview> preview(List<InquiryItemDraft> items);

  Future<InquiryModel> createInquiry({
    required Set<String> categoryIds,
    required List<String> contactIds,
    required List<InquiryItemDraft> items,
    required bool simulate,
    required bool confirmDuplicates,
  });

  Future<List<InquiryModel>> getInquiries(InquiryFilter filter);

  Future<InquiryModel> getInquiry(String id);

  Future<InquiryDraft> getDraft(String id);

  /// `pause`, `resume`, `cancel` ou `resend-failed`.
  Future<InquiryModel> control(String id, String action);

  Future<InquiryPhoto> uploadPhoto(Uint8List bytes, String fileName);

  Future<Uint8List> getPhoto(String id);
}

class InquiryRemoteDataSourceImpl implements InquiryRemoteDataSource {
  final Dio dio;

  InquiryRemoteDataSourceImpl(this.dio);

  @override
  Future<InquirySettings> getSettings() async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '/inquiries/settings',
      );
      return InquirySupportModel.settingsFromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioException(
        e,
        fallback: 'Não foi possível carregar as configurações de consulta.',
      );
    }
  }

  @override
  Future<InquiryPreview> preview(List<InquiryItemDraft> items) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/inquiries/preview',
        data: {'items': InquirySupportModel.encodeItems(items)},
      );
      return InquirySupportModel.previewFromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioException(e, fallback: 'Não foi possível gerar a prévia.');
    }
  }

  @override
  Future<InquiryModel> createInquiry({
    required Set<String> categoryIds,
    required List<String> contactIds,
    required List<InquiryItemDraft> items,
    required bool simulate,
    required bool confirmDuplicates,
  }) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/inquiries',
        data: {
          'categoryIds': categoryIds.toList(),
          'contactIds': contactIds,
          'items': InquirySupportModel.encodeItems(items),
          'simulate': simulate,
          'confirmDuplicates': confirmDuplicates,
        },
      );
      return InquiryModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioException(e, fallback: 'Não foi possível enviar a consulta.');
    }
  }

  @override
  Future<List<InquiryModel>> getInquiries(InquiryFilter filter) async {
    try {
      final item = filter.item?.trim();
      final response = await dio.get<List<dynamic>>(
        '/inquiries',
        queryParameters: {
          if (filter.from != null)
            'from': InquirySupportModel.formatDate(filter.from!),
          if (filter.to != null)
            'to': InquirySupportModel.formatDate(filter.to!),
          'categoryId': ?filter.categoryId,
          if (item != null && item.isNotEmpty) 'item': item,
          'simulated': ?filter.simulated,
        },
      );
      return response.data!
          .map((json) => InquiryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw mapDioException(
        e,
        fallback: 'Não foi possível carregar o histórico de consultas.',
      );
    }
  }

  @override
  Future<InquiryModel> getInquiry(String id) async {
    try {
      final response = await dio.get<Map<String, dynamic>>('/inquiries/$id');
      return InquiryModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioException(e, fallback: 'Não foi possível carregar a consulta.');
    }
  }

  @override
  Future<InquiryDraft> getDraft(String id) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '/inquiries/$id/draft',
      );
      return InquirySupportModel.draftFromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioException(
        e,
        fallback: 'Não foi possível repetir a consulta.',
      );
    }
  }

  @override
  Future<InquiryModel> control(String id, String action) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/inquiries/$id/$action',
      );
      return InquiryModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioException(
        e,
        fallback: 'Não foi possível atualizar o envio.',
      );
    }
  }

  @override
  Future<InquiryPhoto> uploadPhoto(Uint8List bytes, String fileName) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/inquiry-photos',
        data: FormData.fromMap({
          'file': MultipartFile.fromBytes(bytes, filename: fileName),
        }),
      );
      return InquirySupportModel.photoFromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioException(e, fallback: 'Não foi possível enviar a foto.');
    }
  }

  @override
  Future<Uint8List> getPhoto(String id) async {
    try {
      final response = await dio.get<List<int>>(
        '/inquiry-photos/$id',
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data!);
    } on DioException catch (e) {
      throw mapDioException(e, fallback: 'Não foi possível carregar a foto.');
    }
  }
}
