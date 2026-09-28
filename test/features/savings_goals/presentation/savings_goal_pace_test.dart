import 'package:flutter_test/flutter_test.dart';

import 'package:olie/features/planned_items/domain/entities/planned_item.dart';
import 'package:olie/features/planned_items/domain/entities/planned_item_priority.dart';
import 'package:olie/features/savings_goals/domain/entities/savings_goal.dart';
import 'package:olie/features/savings_goals/domain/entities/savings_goal_period.dart';
import 'package:olie/features/savings_goals/presentation/widgets/savings_goal_pace.dart';

void main() {
  SavingsGoal goal(double amount, SavingsGoalPeriod period) => SavingsGoal(
    id: 'g1',
    name: 'Geladeira',
    amount: amount,
    period: period,
    plannedItemId: 'p1',
  );

  PlannedItem item(double value, int daysAhead) {
    final now = DateTime.now();
    return PlannedItem(
      id: 'p1',
      name: 'Geladeira nova',
      priority: PlannedItemPriority.essential,
      estimatedValue: value,
      estimatedDate: DateTime(now.year, now.month, now.day + daysAhead),
    );
  }

  test('converts every period to its monthly equivalent', () {
    expect(goal(300, SavingsGoalPeriod.monthly).monthlyAmount, 300);
    expect(goal(600, SavingsGoalPeriod.semiAnnual).monthlyAmount, 100);
    expect(goal(1200, SavingsGoalPeriod.annual).monthlyAmount, 100);
    expect(
      goal(70, SavingsGoalPeriod.weekly).monthlyAmount,
      closeTo(304.4, 0.01),
    );
  });

  test('is on time when the pace reaches the value before the date', () {
    final pace = SavingsPace.of(
      goal(500, SavingsGoalPeriod.monthly),
      item(2000, 180),
    )!;

    expect(pace.monthsNeeded, 4);
    expect(pace.onTime, isTrue);
    expect(pace.neededLabel, '~4 meses');
  });

  test('is late when the pace needs more time than the date allows', () {
    final pace = SavingsPace.of(
      goal(100, SavingsGoalPeriod.monthly),
      item(2000, 60),
    )!;

    expect(pace.onTime, isFalse);
  });

  test('has no pace without a linked item', () {
    expect(SavingsPace.of(goal(100, SavingsGoalPeriod.monthly), null), isNull);
  });
}
