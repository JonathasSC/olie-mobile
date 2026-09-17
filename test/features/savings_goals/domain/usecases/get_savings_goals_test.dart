import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/savings_goals/domain/entities/savings_goal.dart';
import 'package:olie/features/savings_goals/domain/entities/savings_goal_period.dart';
import 'package:olie/features/savings_goals/domain/repositories/savings_goal_repository.dart';
import 'package:olie/features/savings_goals/domain/usecases/get_savings_goals.dart';

class MockSavingsGoalRepository extends Mock
    implements SavingsGoalRepository {}

void main() {
  late MockSavingsGoalRepository repository;
  late GetSavingsGoals usecase;

  setUp(() {
    repository = MockSavingsGoalRepository();
    usecase = GetSavingsGoals(repository);
  });

  const goals = [
    SavingsGoal(
      id: 'uuid',
      name: 'Viagem de fim de ano',
      amount: 500,
      period: SavingsGoalPeriod.monthly,
    ),
  ];

  test(
    'deve retornar a lista de metas quando o repositório é bem-sucedido',
    () async {
      when(
        () => repository.getSavingsGoals(),
      ).thenAnswer((_) async => const Right(goals));

      final result = await usecase(const NoParams());

      expect(result, const Right(goals));
      verify(() => repository.getSavingsGoals()).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
