import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/savings_goals/domain/entities/savings_goal.dart';
import 'package:olie/features/savings_goals/domain/entities/savings_goal_period.dart';
import 'package:olie/features/savings_goals/domain/usecases/add_savings_goal.dart';
import 'package:olie/features/savings_goals/domain/usecases/delete_savings_goal.dart';
import 'package:olie/features/savings_goals/domain/usecases/get_savings_goals.dart';
import 'package:olie/features/savings_goals/domain/usecases/update_savings_goal.dart';

part 'savings_goal_event.dart';
part 'savings_goal_state.dart';

class SavingsGoalBloc extends Bloc<SavingsGoalEvent, SavingsGoalState> {
  final GetSavingsGoals getSavingsGoals;
  final AddSavingsGoal addSavingsGoal;
  final UpdateSavingsGoal updateSavingsGoal;
  final DeleteSavingsGoal deleteSavingsGoal;

  SavingsGoalBloc({
    required this.getSavingsGoals,
    required this.addSavingsGoal,
    required this.updateSavingsGoal,
    required this.deleteSavingsGoal,
  }) : super(const SavingsGoalState()) {
    on<SavingsGoalsRequested>(_onSavingsGoalsRequested);
    on<SavingsGoalAdded>(_onSavingsGoalAdded);
    on<SavingsGoalUpdated>(_onSavingsGoalUpdated);
    on<SavingsGoalDeleted>(_onSavingsGoalDeleted);
  }

  Future<void> _onSavingsGoalsRequested(
    SavingsGoalsRequested event,
    Emitter<SavingsGoalState> emit,
  ) async {
    emit(state.copyWith(status: SavingsGoalStatus.loading));

    final result = await getSavingsGoals(const NoParams());

    result.fold(
      (failure) => emit(state.copyWith(
        status: SavingsGoalStatus.failure,
        errorMessage: failure.message,
      )),
      (goals) => emit(state.copyWith(
        status: SavingsGoalStatus.success,
        goals: goals,
      )),
    );
  }

  Future<void> _onSavingsGoalAdded(
    SavingsGoalAdded event,
    Emitter<SavingsGoalState> emit,
  ) async {
    final result = await addSavingsGoal(
      AddSavingsGoalParams(
        name: event.name,
        amount: event.amount,
        period: event.period,
        plannedItemId: event.plannedItemId,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: SavingsGoalStatus.failure,
        errorMessage: failure.message,
      )),
      (goal) => emit(state.copyWith(
        status: SavingsGoalStatus.success,
        goals: [goal, ...state.goals],
      )),
    );
  }

  Future<void> _onSavingsGoalUpdated(
    SavingsGoalUpdated event,
    Emitter<SavingsGoalState> emit,
  ) async {
    final result = await updateSavingsGoal(
      UpdateSavingsGoalParams(
        id: event.id,
        name: event.name,
        amount: event.amount,
        period: event.period,
        plannedItemId: event.plannedItemId,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: SavingsGoalStatus.failure,
        errorMessage: failure.message,
      )),
      (updated) => emit(state.copyWith(
        status: SavingsGoalStatus.success,
        goals: [
          for (final goal in state.goals)
            if (goal.id == updated.id) updated else goal,
        ],
      )),
    );
  }

  Future<void> _onSavingsGoalDeleted(
    SavingsGoalDeleted event,
    Emitter<SavingsGoalState> emit,
  ) async {
    final result = await deleteSavingsGoal(
      DeleteSavingsGoalParams(event.id),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: SavingsGoalStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: SavingsGoalStatus.success,
        goals: state.goals.where((goal) => goal.id != event.id).toList(),
      )),
    );
  }
}
