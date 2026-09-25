enum LifespanUnit {
  days,
  weeks,
  months,
  years;

  String get apiValue {
    switch (this) {
      case LifespanUnit.days:
        return 'DAYS';
      case LifespanUnit.weeks:
        return 'WEEKS';
      case LifespanUnit.months:
        return 'MONTHS';
      case LifespanUnit.years:
        return 'YEARS';
    }
  }

  String get label {
    switch (this) {
      case LifespanUnit.days:
        return 'Dias';
      case LifespanUnit.weeks:
        return 'Semanas';
      case LifespanUnit.months:
        return 'Meses';
      case LifespanUnit.years:
        return 'Anos';
    }
  }

  static LifespanUnit fromApiValue(String value) {
    switch (value) {
      case 'DAYS':
        return LifespanUnit.days;
      case 'WEEKS':
        return LifespanUnit.weeks;
      case 'MONTHS':
        return LifespanUnit.months;
      case 'YEARS':
        return LifespanUnit.years;
      default:
        throw ArgumentError('Unidade de vida útil desconhecida: $value');
    }
  }
}
