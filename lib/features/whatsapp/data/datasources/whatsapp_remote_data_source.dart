import 'package:dio/dio.dart';

import 'package:olie/core/network/api_error_mapper.dart';
import 'package:olie/features/whatsapp/data/models/whatsapp_connection_model.dart';

abstract class WhatsAppRemoteDataSource {
  Future<WhatsAppConnectionModel> getConnection();

  Future<WhatsAppConnectionModel> connect();

  Future<WhatsAppConnectionModel> disconnect();
}

class WhatsAppRemoteDataSourceImpl implements WhatsAppRemoteDataSource {
  static const _path = '/whatsapp/connection';

  final Dio dio;

  WhatsAppRemoteDataSourceImpl(this.dio);

  @override
  Future<WhatsAppConnectionModel> getConnection() =>
      _call(() => dio.get<Map<String, dynamic>>(_path));

  @override
  Future<WhatsAppConnectionModel> connect() =>
      _call(() => dio.post<Map<String, dynamic>>(_path));

  @override
  Future<WhatsAppConnectionModel> disconnect() =>
      _call(() => dio.delete<Map<String, dynamic>>(_path));

  Future<WhatsAppConnectionModel> _call(
    Future<Response<Map<String, dynamic>>> Function() request,
  ) async {
    try {
      final response = await request();
      return WhatsAppConnectionModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioException(
        e,
        fallback: 'Não foi possível falar com o serviço de WhatsApp.',
      );
    }
  }
}
