part of 'savings_goal_bloc.dart';

abstract class SavingsGoalEvent extends Equatable {
  const SavingsGoalEvent();

  @override
  List<Object?> get props => [];
}

class SavingsGoalsRequested extends SavingsGoalEvent {
  const SavingsGoalsRequested();
}

class SavingsGoalAdded extends SavingsGoalEvent {
  final String name;
  final double amount;
  final SavingsGoalPeriod period;
  final String? plannedItemId;

  const SavingsGoalAdded({
    required this.name,
    required this.amount,
    required this.period,
    this.plannedItemId,
  });

  @override
  List<Object?> get props => [name, amount, period, plannedItemId];
}

class SavingsGoalUpdated extends SavingsGoalEvent {
  final String id;
  final String name;
  final double amount;
  final SavingsGoalPeriod period;
  final String? plannedItemId;

  const SavingsGoalUpdated({
    required this.id,
    required this.name,
    required this.amount,
    required this.period,
    this.plannedItemId,
  });

  @override
  List<Object?> get props => [id, name, amount, period, plannedItemId];
}

class SavingsGoalDeleted extends SavingsGoalEvent {
  final String id;

  const SavingsGoalDeleted(this.id);

  @override
  List<Object?> get props => [id];
}
