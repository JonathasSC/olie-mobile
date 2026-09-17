enum SavingsGoalPeriod {
  daily,
  weekly,
  monthly,
  quarterly,
  semiAnnual,
  annual;

  String get apiValue {
    switch (this) {
      case SavingsGoalPeriod.daily:
        return 'DAILY';
      case SavingsGoalPeriod.weekly:
        return 'WEEKLY';
      case SavingsGoalPeriod.monthly:
        return 'MONTHLY';
      case SavingsGoalPeriod.quarterly:
        return 'QUARTERLY';
      case SavingsGoalPeriod.semiAnnual:
        return 'SEMI_ANNUAL';
      case SavingsGoalPeriod.annual:
        return 'ANNUAL';
    }
  }

  String get label {
    switch (this) {
      case SavingsGoalPeriod.daily:
        return 'Diário';
      case SavingsGoalPeriod.weekly:
        return 'Semanal';
      case SavingsGoalPeriod.monthly:
        return 'Mensal';
      case SavingsGoalPeriod.quarterly:
        return 'Trimestral';
      case SavingsGoalPeriod.semiAnnual:
        return 'Semestral';
      case SavingsGoalPeriod.annual:
        return 'Anual';
    }
  }

  static SavingsGoalPeriod fromApiValue(String value) {
    switch (value) {
      case 'DAILY':
        return SavingsGoalPeriod.daily;
      case 'WEEKLY':
        return SavingsGoalPeriod.weekly;
      case 'MONTHLY':
        return SavingsGoalPeriod.monthly;
      case 'QUARTERLY':
        return SavingsGoalPeriod.quarterly;
      case 'SEMI_ANNUAL':
        return SavingsGoalPeriod.semiAnnual;
      case 'ANNUAL':
        return SavingsGoalPeriod.annual;
      default:
        throw ArgumentError('Período desconhecido: $value');
    }
  }
}
