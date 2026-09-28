import 'package:flutter_test/flutter_test.dart';

import 'package:olie/core/presentation/formatters.dart';

void main() {
  group('formatCurrency', () {
    test('uses Brazilian separators', () {
      expect(formatCurrency(1234.5), 'R\$ 1.234,50');
      expect(formatCurrency(0.9), 'R\$ 0,90');
      expect(formatCurrency(1000000), 'R\$ 1.000.000,00');
    });

    test('keeps the sign of negative values', () {
      expect(formatCurrency(-89.9), '-R\$ 89,90');
    });
  });

  group('formatRelativeDays', () {
    test('names the nearest days', () {
      expect(formatRelativeDays(0), 'hoje');
      expect(formatRelativeDays(1), 'amanhã');
      expect(formatRelativeDays(-1), 'ontem');
    });

    test('counts further days in both directions', () {
      expect(formatRelativeDays(12), 'em 12 dias');
      expect(formatRelativeDays(-3), 'há 3 dias');
    });
  });

  test('daysUntil counts calendar days from today', () {
    final now = DateTime.now();
    expect(daysUntil(DateTime(now.year, now.month, now.day, 23, 59)), 0);
    expect(daysUntil(DateTime(now.year, now.month, now.day + 5)), 5);
    expect(daysUntil(DateTime(now.year, now.month, now.day - 2)), -2);
  });
}
