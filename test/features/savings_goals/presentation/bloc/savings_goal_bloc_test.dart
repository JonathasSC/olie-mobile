import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/savings_goals/domain/entities/savings_goal.dart';
import 'package:olie/features/savings_goals/domain/entities/savings_goal_period.dart';
import 'package:olie/features/savings_goals/domain/usecases/add_savings_goal.dart';
import 'package:olie/features/savings_goals/domain/usecases/delete_savings_goal.dart';
import 'package:olie/features/savings_goals/domain/usecases/get_savings_goals.dart';
import 'package:olie/features/savings_goals/domain/usecases/update_savings_goal.dart';
import 'package:olie/features/savings_goals/presentation/bloc/savings_goal_bloc.dart';

class MockGetSavingsGoals extends Mock implements GetSavingsGoals {}

class MockAddSavingsGoal extends Mock implements AddSavingsGoal {}

class MockUpdateSavingsGoal extends Mock implements UpdateSavingsGoal {}

class MockDeleteSavingsGoal extends Mock implements DeleteSavingsGoal {}

void main() {
  late MockGetSavingsGoals getSavingsGoals;
  late MockAddSavingsGoal addSavingsGoal;
  late MockUpdateSavingsGoal updateSavingsGoal;
  late MockDeleteSavingsGoal deleteSavingsGoal;

  const goal = SavingsGoal(
    id: 'uuid',
    name: 'Viagem de fim de ano',
    amount: 500,
    period: SavingsGoalPeriod.monthly,
  );

  setUpAll(() {
    registerFallbackValue(
      const AddSavingsGoalParams(
        name: 'fallback',
        amount: 1,
        period: SavingsGoalPeriod.monthly,
      ),
    );
    registerFallbackValue(
      const UpdateSavingsGoalParams(
        id: 'fallback',
        name: 'fallback',
        amount: 1,
        period: SavingsGoalPeriod.monthly,
      ),
    );
    registerFallbackValue(const DeleteSavingsGoalParams('fallback'));
  });

  setUp(() {
    getSavingsGoals = MockGetSavingsGoals();
    addSavingsGoal = MockAddSavingsGoal();
    updateSavingsGoal = MockUpdateSavingsGoal();
    deleteSavingsGoal = MockDeleteSavingsGoal();
  });

  SavingsGoalBloc buildBloc() => SavingsGoalBloc(
        getSavingsGoals: getSavingsGoals,
        addSavingsGoal: addSavingsGoal,
        updateSavingsGoal: updateSavingsGoal,
        deleteSavingsGoal: deleteSavingsGoal,
      );

  blocTest<SavingsGoalBloc, SavingsGoalState>(
    'emite [loading, success] quando as metas são carregadas',
    build: () {
      when(
        () => getSavingsGoals(const NoParams()),
      ).thenAnswer((_) async => const Right([goal]));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const SavingsGoalsRequested()),
    expect: () => [
      const SavingsGoalState(status: SavingsGoalStatus.loading),
      const SavingsGoalState(status: SavingsGoalStatus.success, goals: [goal]),
    ],
  );

  blocTest<SavingsGoalBloc, SavingsGoalState>(
    'emite [failure] quando o carregamento falha',
    build: () {
      when(() => getSavingsGoals(const NoParams())).thenAnswer(
        (_) async =>
            const Left(ServerFailure('Erro ao comunicar com o servidor.')),
      );
      return buildBloc();
    },
    act: (bloc) => bloc.add(const SavingsGoalsRequested()),
    expect: () => [
      const SavingsGoalState(status: SavingsGoalStatus.loading),
      const SavingsGoalState(
        status: SavingsGoalStatus.failure,
        errorMessage: 'Erro ao comunicar com o servidor.',
      ),
    ],
  );

  blocTest<SavingsGoalBloc, SavingsGoalState>(
    'adiciona a meta criada ao início da lista',
    build: () {
      when(
        () => addSavingsGoal(any()),
      ).thenAnswer((_) async => const Right(goal));
      return buildBloc();
    },
    act: (bloc) => bloc.add(
      SavingsGoalAdded(
        name: goal.name,
        amount: goal.amount,
        period: goal.period,
      ),
    ),
    expect: () => [
      const SavingsGoalState(status: SavingsGoalStatus.success, goals: [goal]),
    ],
  );

  blocTest<SavingsGoalBloc, SavingsGoalState>(
    'remove a meta excluída da lista',
    seed: () => const SavingsGoalState(goals: [goal]),
    build: () {
      when(
        () => deleteSavingsGoal(any()),
      ).thenAnswer((_) async => const Right(null));
      return buildBloc();
    },
    act: (bloc) => bloc.add(SavingsGoalDeleted(goal.id)),
    expect: () => [
      const SavingsGoalState(status: SavingsGoalStatus.success, goals: []),
    ],
  );
}
