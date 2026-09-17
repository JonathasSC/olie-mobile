import 'package:olie/features/savings_goals/domain/entities/savings_goal.dart';
import 'package:olie/features/savings_goals/domain/entities/savings_goal_period.dart';

class SavingsGoalModel extends SavingsGoal {
  const SavingsGoalModel({
    required super.id,
    required super.name,
    required super.amount,
    required super.period,
    super.plannedItemId,
  });

  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) {
    return SavingsGoalModel(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      period: SavingsGoalPeriod.fromApiValue(json['period'] as String),
      plannedItemId: json['plannedItemId'] as String?,
    );
  }

  static Map<String, dynamic> encodeRequest({
    required String name,
    required double amount,
    required SavingsGoalPeriod period,
    String? plannedItemId,
  }) {
    return {
      'name': name,
      'amount': amount,
      'period': period.apiValue,
      'plannedItemId': plannedItemId,
    };
  }
}
