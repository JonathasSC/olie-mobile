import 'package:dio/dio.dart';

import 'package:olie/core/error/exceptions.dart';
import 'package:olie/features/wear_items/data/models/wear_item_model.dart';
import 'package:olie/features/wear_items/domain/entities/lifespan_unit.dart';
import 'package:olie/features/wear_items/domain/entities/wear_item_detail.dart';
import 'package:olie/features/wear_items/domain/entities/wear_status.dart';

abstract class WearItemRemoteDataSource {
  Future<List<WearItemModel>> getWearItems({
    Set<WearStatus> statuses = const {},
  });

  Future<WearItemDetail> getWearItemDetail(String id);

  Future<WearItemModel> addWearItem({
    required String name,
    required int expectedLifespan,
    required LifespanUnit expectedLifespanUnit,
    required DateTime purchaseDate,
    DateTime? installationDate,
    double? purchaseValue,
    String? categoryId,
  });

  Future<WearItemModel> updateWearItem({
    required String id,
    required String name,
    required int expectedLifespan,
    required LifespanUnit expectedLifespanUnit,
    required DateTime purchaseDate,
    DateTime? installationDate,
    double? purchaseValue,
    String? categoryId,
  });

  Future<void> deleteWearItem(String id);

  Future<WearItemModel> replaceWearItem({
    required String id,
    required DateTime purchaseDate,
    DateTime? installationDate,
    DateTime? removalDate,
    double? purchaseValue,
    String? paymentMethod,
  });
}

class WearItemRemoteDataSourceImpl implements WearItemRemoteDataSource {
  final Dio dio;

  WearItemRemoteDataSourceImpl(this.dio);

  @override
  Future<List<WearItemModel>> getWearItems({
    Set<WearStatus> statuses = const {},
  }) async {
    try {
      final response = await dio.get<List<dynamic>>(
        '/wear-items',
        // Lista vira `?status=NEAR_END&status=OVERDUE` (param repetido).
        queryParameters: {
          if (statuses.isNotEmpty)
            'status': statuses.map((status) => status.apiValue).toList(),
        },
        options: Options(listFormat: ListFormat.multi),
      );
      return response.data!
          .map((json) => WearItemModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioException(
        e,
        fallback: 'Não foi possível carregar os itens de desgaste.',
      );
    }
  }

  @override
  Future<WearItemDetail> getWearItemDetail(String id) async {
    try {
      final response = await dio.get<Map<String, dynamic>>('/wear-items/$id');
      return WearItemModel.detailFromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioException(
        e,
        fallback: 'Não foi possível carregar o histórico do item.',
      );
    }
  }

  @override
  Future<WearItemModel> addWearItem({
    required String name,
    required int expectedLifespan,
    required LifespanUnit expectedLifespanUnit,
    required DateTime purchaseDate,
    DateTime? installationDate,
    double? purchaseValue,
    String? categoryId,
  }) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/wear-items',
        data: WearItemModel.encodeRequest(
          name: name,
          expectedLifespan: expectedLifespan,
          expectedLifespanUnit: expectedLifespanUnit,
          purchaseDate: purchaseDate,
          installationDate: installationDate,
          purchaseValue: purchaseValue,
          categoryId: categoryId,
        ),
      );
      return WearItemModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioException(
        e,
        fallback: 'Não foi possível cadastrar o item.',
      );
    }
  }

  @override
  Future<WearItemModel> updateWearItem({
    required String id,
    required String name,
    required int expectedLifespan,
    required LifespanUnit expectedLifespanUnit,
    required DateTime purchaseDate,
    DateTime? installationDate,
    double? purchaseValue,
    String? categoryId,
  }) async {
    try {
      final response = await dio.put<Map<String, dynamic>>(
        '/wear-items/$id',
        data: WearItemModel.encodeRequest(
          name: name,
          expectedLifespan: expectedLifespan,
          expectedLifespanUnit: expectedLifespanUnit,
          purchaseDate: purchaseDate,
          installationDate: installationDate,
          purchaseValue: purchaseValue,
          categoryId: categoryId,
        ),
      );
      return WearItemModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioException(
        e,
        fallback: 'Não foi possível atualizar o item.',
      );
    }
  }

  @override
  Future<void> deleteWearItem(String id) async {
    try {
      await dio.delete<void>('/wear-items/$id');
    } on DioException catch (e) {
      throw _mapDioException(e, fallback: 'Não foi possível remover o item.');
    }
  }

  @override
  Future<WearItemModel> replaceWearItem({
    required String id,
    required DateTime purchaseDate,
    DateTime? installationDate,
    DateTime? removalDate,
    double? purchaseValue,
    String? paymentMethod,
  }) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/wear-items/$id/replace',
        data: WearItemModel.encodeReplaceRequest(
          purchaseDate: purchaseDate,
          installationDate: installationDate,
          removalDate: removalDate,
          purchaseValue: purchaseValue,
          paymentMethod: paymentMethod,
        ),
      );
      return WearItemModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioException(
        e,
        fallback: 'Não foi possível registrar a troca.',
      );
    }
  }

  Exception _mapDioException(DioException e, {required String fallback}) {
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const NetworkException();
      default:
        final data = e.response?.data;
        final message = data is Map<String, dynamic>
            ? data['message'] as String?
            : null;
        return ServerException(message ?? fallback);
    }
  }
}
