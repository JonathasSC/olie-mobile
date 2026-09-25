String formatWearDate(DateTime date) {
  String twoDigits(int value) => value.toString().padLeft(2, '0');
  return '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year}';
}

String formatWearCurrency(double value) => 'R\$ ${value.toStringAsFixed(2)}';

String formatDays(int days) => days == 1 ? '1 dia' : '$days dias';

/// Converte o texto de um campo de valor ("89,90" ou "89.90").
double? parseWearValue(String raw) =>
    double.tryParse(raw.trim().replaceAll(',', '.'));
