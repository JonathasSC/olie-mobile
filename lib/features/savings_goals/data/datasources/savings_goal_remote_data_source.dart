import 'package:dio/dio.dart';

import 'package:olie/core/error/exceptions.dart';
import 'package:olie/features/savings_goals/data/models/savings_goal_model.dart';
import 'package:olie/features/savings_goals/domain/entities/savings_goal_period.dart';

abstract class SavingsGoalRemoteDataSource {
  Future<List<SavingsGoalModel>> getSavingsGoals();

  Future<SavingsGoalModel> addSavingsGoal({
    required String name,
    required double amount,
    required SavingsGoalPeriod period,
    String? plannedItemId,
  });

  Future<SavingsGoalModel> updateSavingsGoal({
    required String id,
    required String name,
    required double amount,
    required SavingsGoalPeriod period,
    String? plannedItemId,
  });

  Future<void> deleteSavingsGoal(String id);
}

class SavingsGoalRemoteDataSourceImpl implements SavingsGoalRemoteDataSource {
  final Dio dio;

  SavingsGoalRemoteDataSourceImpl(this.dio);

  @override
  Future<List<SavingsGoalModel>> getSavingsGoals() async {
    try {
      final response = await dio.get<List<dynamic>>('/savings-goals');
      return response.data!
          .map(
            (json) => SavingsGoalModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      throw _mapDioException(
        e,
        fallback: 'Não foi possível carregar as metas de economia.',
      );
    }
  }

  @override
  Future<SavingsGoalModel> addSavingsGoal({
    required String name,
    required double amount,
    required SavingsGoalPeriod period,
    String? plannedItemId,
  }) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/savings-goals',
        data: SavingsGoalModel.encodeRequest(
          name: name,
          amount: amount,
          period: period,
          plannedItemId: plannedItemId,
        ),
      );
      return SavingsGoalModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioException(
        e,
        fallback: 'Não foi possível criar a meta de economia.',
      );
    }
  }

  @override
  Future<SavingsGoalModel> updateSavingsGoal({
    required String id,
    required String name,
    required double amount,
    required SavingsGoalPeriod period,
    String? plannedItemId,
  }) async {
    try {
      final response = await dio.put<Map<String, dynamic>>(
        '/savings-goals/$id',
        data: SavingsGoalModel.encodeRequest(
          name: name,
          amount: amount,
          period: period,
          plannedItemId: plannedItemId,
        ),
      );
      return SavingsGoalModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioException(
        e,
        fallback: 'Não foi possível atualizar a meta de economia.',
      );
    }
  }

  @override
  Future<void> deleteSavingsGoal(String id) async {
    try {
      await dio.delete<void>('/savings-goals/$id');
    } on DioException catch (e) {
      throw _mapDioException(
        e,
        fallback: 'Não foi possível remover a meta de economia.',
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
