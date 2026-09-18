enum AppNotificationType {
  purchaseDateApproaching,
  sufficientBalance;

  String get apiValue {
    switch (this) {
      case AppNotificationType.purchaseDateApproaching:
        return 'PURCHASE_DATE_APPROACHING';
      case AppNotificationType.sufficientBalance:
        return 'SUFFICIENT_BALANCE';
    }
  }

  String get label {
    switch (this) {
      case AppNotificationType.purchaseDateApproaching:
        return 'Data da compra se aproximando';
      case AppNotificationType.sufficientBalance:
        return 'Saldo suficiente';
    }
  }

  static AppNotificationType fromApiValue(String value) {
    switch (value) {
      case 'PURCHASE_DATE_APPROACHING':
        return AppNotificationType.purchaseDateApproaching;
      case 'SUFFICIENT_BALANCE':
        return AppNotificationType.sufficientBalance;
      default:
        throw ArgumentError('Tipo de notificação desconhecido: $value');
    }
  }
}
