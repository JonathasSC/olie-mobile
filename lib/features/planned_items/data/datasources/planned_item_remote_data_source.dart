import 'package:dio/dio.dart';

import 'package:olie/core/error/exceptions.dart';
import 'package:olie/features/planned_items/data/models/planned_item_model.dart';
import 'package:olie/features/planned_items/domain/entities/planned_item_priority.dart';

abstract class PlannedItemRemoteDataSource {
  Future<List<PlannedItemModel>> getPlannedItems();

  Future<PlannedItemModel> addPlannedItem({
    required String name,
    required PlannedItemPriority priority,
    required double estimatedValue,
    required DateTime estimatedDate,
    String? categoryId,
  });

  Future<PlannedItemModel> updatePlannedItem({
    required String id,
    required String name,
    required PlannedItemPriority priority,
    required double estimatedValue,
    required DateTime estimatedDate,
    String? categoryId,
  });

  Future<void> deletePlannedItem(String id);

  Future<void> completePlannedItem({
    required String id,
    required String paymentMethod,
    double? value,
  });
}

class PlannedItemRemoteDataSourceImpl implements PlannedItemRemoteDataSource {
  final Dio dio;

  PlannedItemRemoteDataSourceImpl(this.dio);

  @override
  Future<List<PlannedItemModel>> getPlannedItems() async {
    try {
      final response = await dio.get<List<dynamic>>('/planned-items');
      return response.data!
          .map(
            (json) => PlannedItemModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      throw _mapDioException(
        e,
        fallback: 'Não foi possível carregar os itens planejados.',
      );
    }
  }

  @override
  Future<PlannedItemModel> addPlannedItem({
    required String name,
    required PlannedItemPriority priority,
    required double estimatedValue,
    required DateTime estimatedDate,
    String? categoryId,
  }) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/planned-items',
        data: PlannedItemModel.encodeRequest(
          name: name,
          priority: priority,
          estimatedValue: estimatedValue,
          estimatedDate: estimatedDate,
          categoryId: categoryId,
        ),
      );
      return PlannedItemModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioException(
        e,
        fallback: 'Não foi possível criar o item planejado.',
      );
    }
  }

  @override
  Future<PlannedItemModel> updatePlannedItem({
    required String id,
    required String name,
    required PlannedItemPriority priority,
    required double estimatedValue,
    required DateTime estimatedDate,
    String? categoryId,
  }) async {
    try {
      final response = await dio.put<Map<String, dynamic>>(
        '/planned-items/$id',
        data: PlannedItemModel.encodeRequest(
          name: name,
          priority: priority,
          estimatedValue: estimatedValue,
          estimatedDate: estimatedDate,
          categoryId: categoryId,
        ),
      );
      return PlannedItemModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioException(
        e,
        fallback: 'Não foi possível atualizar o item planejado.',
      );
    }
  }

  @override
  Future<void> deletePlannedItem(String id) async {
    try {
      await dio.delete<void>('/planned-items/$id');
    } on DioException catch (e) {
      throw _mapDioException(
        e,
        fallback: 'Não foi possível remover o item planejado.',
      );
    }
  }

  @override
  Future<void> completePlannedItem({
    required String id,
    required String paymentMethod,
    double? value,
  }) async {
    try {
      await dio.patch<Map<String, dynamic>>(
        '/planned-items/$id/complete',
        data: {'paymentMethod': paymentMethod, 'value': ?value},
      );
    } on DioException catch (e) {
      throw _mapDioException(
        e,
        fallback: 'Não foi possível efetivar a compra.',
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
