enum AppNotificationType {
  purchaseDateApproaching,
  sufficientBalance,
  wearItemReplacementApproaching;

  String get apiValue {
    switch (this) {
      case AppNotificationType.purchaseDateApproaching:
        return 'PURCHASE_DATE_APPROACHING';
      case AppNotificationType.sufficientBalance:
        return 'SUFFICIENT_BALANCE';
      case AppNotificationType.wearItemReplacementApproaching:
        return 'WEAR_ITEM_REPLACEMENT_APPROACHING';
    }
  }

  String get label {
    switch (this) {
      case AppNotificationType.purchaseDateApproaching:
        return 'Data da compra se aproximando';
      case AppNotificationType.sufficientBalance:
        return 'Saldo suficiente';
      case AppNotificationType.wearItemReplacementApproaching:
        return 'Troca de item se aproximando';
    }
  }

  static AppNotificationType fromApiValue(String value) {
    switch (value) {
      case 'PURCHASE_DATE_APPROACHING':
        return AppNotificationType.purchaseDateApproaching;
      case 'SUFFICIENT_BALANCE':
        return AppNotificationType.sufficientBalance;
      case 'WEAR_ITEM_REPLACEMENT_APPROACHING':
        return AppNotificationType.wearItemReplacementApproaching;
      default:
        throw ArgumentError('Tipo de notificação desconhecido: $value');
    }
  }
}
