import 'package:flutter/material.dart';

const _months = [
  'jan',
  'fev',
  'mar',
  'abr',
  'mai',
  'jun',
  'jul',
  'ago',
  'set',
  'out',
  'nov',
  'dez',
];

const _weekdays = ['seg', 'ter', 'qua', 'qui', 'sex', 'sáb', 'dom'];

String _two(int value) => value.toString().padLeft(2, '0');

/// `27 set` — ou `27 set 2027` quando não é o ano corrente.
String formatShortDate(DateTime date) {
  final local = date.toLocal();
  final base = '${local.day} ${_months[local.month - 1]}';
  return local.year == DateTime.now().year ? base : '$base ${local.year}';
}

/// `27/09/2026`
String formatFullDate(DateTime date) {
  final local = date.toLocal();
  return '${_two(local.day)}/${_two(local.month)}/${local.year}';
}

/// `27/09/2026 14:05`
String formatDateTime(DateTime date) {
  final local = date.toLocal();
  return '${formatFullDate(local)} ${_two(local.hour)}:${_two(local.minute)}';
}

/// `SÁB · 27 SET 2026`
String formatTodayEyebrow(DateTime date) =>
    '${_weekdays[date.weekday - 1]} · ${date.day} ${_months[date.month - 1]} '
            '${date.year}'
        .toUpperCase();

/// `R$ 1.234,50`
String formatCurrency(double value) {
  final negative = value < 0;
  final cents = (value.abs() * 100).round();
  final whole = (cents ~/ 100).toString();
  final buffer = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) buffer.write('.');
    buffer.write(whole[i]);
  }
  return '${negative ? '-' : ''}R\$ $buffer,${_two(cents % 100)}';
}

/// Dias corridos entre hoje e [date] (negativo = já passou).
int daysUntil(DateTime date) {
  final today = DateUtils.dateOnly(DateTime.now());
  return DateUtils.dateOnly(date.toLocal()).difference(today).inDays;
}

/// `hoje`, `amanhã`, `em 12 dias`, `ontem`, `há 3 dias`.
String formatRelativeDays(int days) {
  if (days == 0) return 'hoje';
  if (days == 1) return 'amanhã';
  if (days == -1) return 'ontem';
  return days > 0 ? 'em $days dias' : 'há ${-days} dias';
}
