part of 'savings_goal_bloc.dart';

enum SavingsGoalStatus { initial, loading, success, failure }

class SavingsGoalState extends Equatable {
  final SavingsGoalStatus status;
  final List<SavingsGoal> goals;
  final String? errorMessage;

  const SavingsGoalState({
    this.status = SavingsGoalStatus.initial,
    this.goals = const [],
    this.errorMessage,
  });

  SavingsGoalState copyWith({
    SavingsGoalStatus? status,
    List<SavingsGoal>? goals,
    String? errorMessage,
  }) {
    return SavingsGoalState(
      status: status ?? this.status,
      goals: goals ?? this.goals,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, goals, errorMessage];
}
