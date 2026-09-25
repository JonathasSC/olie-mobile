enum WearStatus {
  inStock,
  ok,
  nearEnd,
  overdue;

  String get apiValue {
    switch (this) {
      case WearStatus.inStock:
        return 'IN_STOCK';
      case WearStatus.ok:
        return 'OK';
      case WearStatus.nearEnd:
        return 'NEAR_END';
      case WearStatus.overdue:
        return 'OVERDUE';
    }
  }

  String get label {
    switch (this) {
      case WearStatus.inStock:
        return 'Em estoque';
      case WearStatus.ok:
        return 'Em uso';
      case WearStatus.nearEnd:
        return 'Perto do fim';
      case WearStatus.overdue:
        return 'Atrasado';
    }
  }

  static WearStatus fromApiValue(String value) {
    switch (value) {
      case 'IN_STOCK':
        return WearStatus.inStock;
      case 'OK':
        return WearStatus.ok;
      case 'NEAR_END':
        return WearStatus.nearEnd;
      case 'OVERDUE':
        return WearStatus.overdue;
      default:
        throw ArgumentError('Status de desgaste desconhecido: $value');
    }
  }
}
