enum PlannedItemPriority {
  essential,
  desirable,
  superfluous;

  String get apiValue {
    switch (this) {
      case PlannedItemPriority.essential:
        return 'ESSENTIAL';
      case PlannedItemPriority.desirable:
        return 'DESIRABLE';
      case PlannedItemPriority.superfluous:
        return 'SUPERFLUOUS';
    }
  }

  String get label {
    switch (this) {
      case PlannedItemPriority.essential:
        return 'Essencial';
      case PlannedItemPriority.desirable:
        return 'Desejável';
      case PlannedItemPriority.superfluous:
        return 'Supérfluo';
    }
  }

  static PlannedItemPriority fromApiValue(String value) {
    switch (value) {
      case 'ESSENTIAL':
        return PlannedItemPriority.essential;
      case 'DESIRABLE':
        return PlannedItemPriority.desirable;
      case 'SUPERFLUOUS':
        return PlannedItemPriority.superfluous;
      default:
        throw ArgumentError('Prioridade desconhecida: $value');
    }
  }
}
