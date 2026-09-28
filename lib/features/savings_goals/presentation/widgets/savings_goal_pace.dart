import 'package:olie/core/presentation/formatters.dart';
import 'package:olie/features/planned_items/domain/entities/planned_item.dart';
import 'package:olie/features/savings_goals/domain/entities/savings_goal.dart';
import 'package:olie/features/savings_goals/domain/entities/savings_goal_period.dart';

const _daysPerMonth = 30.44;

extension SavingsGoalPeriodMath on SavingsGoalPeriod {
  /// Quantos períodos cabem em um mês.
  double get perMonth => switch (this) {
    SavingsGoalPeriod.daily => _daysPerMonth,
    SavingsGoalPeriod.weekly => _daysPerMonth / 7,
    SavingsGoalPeriod.monthly => 1,
    SavingsGoalPeriod.quarterly => 1 / 3,
    SavingsGoalPeriod.semiAnnual => 1 / 6,
    SavingsGoalPeriod.annual => 1 / 12,
  };

  /// Sufixo curto: `/dia`, `/mês`...
  String get suffix => switch (this) {
    SavingsGoalPeriod.daily => '/dia',
    SavingsGoalPeriod.weekly => '/semana',
    SavingsGoalPeriod.monthly => '/mês',
    SavingsGoalPeriod.quarterly => '/trimestre',
    SavingsGoalPeriod.semiAnnual => '/semestre',
    SavingsGoalPeriod.annual => '/ano',
  };
}

extension SavingsGoalMath on SavingsGoal {
  double get monthlyAmount => amount * period.perMonth;
}

/// Ritmo de uma meta em relação à compra vinculada.
class SavingsPace {
  /// Meses necessários para juntar o valor da compra neste ritmo.
  final double monthsNeeded;

  /// Meses até a data prevista da compra (0 se já passou).
  final double monthsAvailable;

  const SavingsPace({
    required this.monthsNeeded,
    required this.monthsAvailable,
  });

  bool get onTime => monthsNeeded <= monthsAvailable;

  static SavingsPace? of(SavingsGoal goal, PlannedItem? item) {
    if (item == null || goal.monthlyAmount <= 0) return null;
    final days = daysUntil(item.estimatedDate);
    return SavingsPace(
      monthsNeeded: item.estimatedValue / goal.monthlyAmount,
      monthsAvailable: days <= 0 ? 0 : days / _daysPerMonth,
    );
  }

  /// `~5 meses`, `menos de 1 mês`.
  String get neededLabel {
    if (monthsNeeded < 1) return 'menos de 1 mês';
    final months = monthsNeeded.ceil();
    return months == 1 ? '~1 mês' : '~$months meses';
  }
}
