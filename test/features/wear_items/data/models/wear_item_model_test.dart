import 'package:flutter_test/flutter_test.dart';

import 'package:olie/features/wear_items/data/models/wear_item_model.dart';
import 'package:olie/features/wear_items/domain/entities/lifespan_unit.dart';
import 'package:olie/features/wear_items/domain/entities/wear_estimate_source.dart';
import 'package:olie/features/wear_items/domain/entities/wear_status.dart';

void main() {
  // Exemplos de `reference/API.md`.
  final json = <String, dynamic>{
    'id': 'uuid',
    'name': 'Filtro de água da cozinha',
    'categoryId': 'cat-uuid',
    'expectedLifespan': 6,
    'expectedLifespanUnit': 'MONTHS',
    'currentCycle': {
      'id': 'cycle-uuid',
      'purchaseDate': '2026-03-10',
      'installationDate': '2026-03-15',
      'purchaseValue': 89.90,
    },
    'estimate': {
      'lifespanDays': 176,
      'source': 'HISTORY',
      'estimatedReplacementDate': '2026-09-07',
      'daysRemaining': -18,
      'wearPercentage': 110,
      'status': 'OVERDUE',
      'suggestedValue': 92.45,
    },
    'cyclesCount': 3,
    'createdAt': '2026-01-05T14:30:00Z',
  };

  test('deve converter o WearItemResponse da API', () {
    final item = WearItemModel.fromJson(json);

    expect(item.name, 'Filtro de água da cozinha');
    expect(item.expectedLifespanUnit, LifespanUnit.months);
    expect(item.currentCycle.installationDate, DateTime(2026, 3, 15));
    expect(item.currentCycle.purchaseValue, 89.90);
    expect(item.estimate.source, WearEstimateSource.history);
    expect(item.estimate.status, WearStatus.overdue);
    expect(item.estimate.daysRemaining, -18);
    expect(item.estimate.estimatedReplacementDate, DateTime(2026, 9, 7));
    expect(item.cyclesCount, 3);
    expect(item.createdAt, DateTime.utc(2026, 1, 5, 14, 30));
  });

  test('deve aceitar item em estoque, sem estimativa de data', () {
    final item = WearItemModel.fromJson({
      ...json,
      'currentCycle': {
        'id': 'cycle-uuid',
        'purchaseDate': '2026-03-10',
        'installationDate': null,
        'purchaseValue': null,
      },
      'estimate': {
        'lifespanDays': 180,
        'source': 'EXPECTED',
        'estimatedReplacementDate': null,
        'daysRemaining': null,
        'wearPercentage': null,
        'status': 'IN_STOCK',
        'suggestedValue': null,
      },
    });

    expect(item.currentCycle.installationDate, isNull);
    expect(item.estimate.status, WearStatus.inStock);
    expect(item.estimate.wearPercentage, isNull);
  });

  test('deve converter o detalhe com histórico', () {
    final detail = WearItemModel.detailFromJson({
      ...json,
      'history': [
        {
          'id': 'old-uuid',
          'purchaseDate': '2025-09-01',
          'installationDate': '2025-09-02',
          'removalDate': '2026-03-15',
          'purchaseValue': 95.00,
          'lifespanDays': 194,
        },
      ],
    });

    expect(detail.item.id, 'uuid');
    expect(detail.history, hasLength(1));
    expect(detail.history.first.removalDate, DateTime(2026, 3, 15));
    expect(detail.history.first.lifespanDays, 194);
  });

  test('deve omitir removalDate e paymentMethod ausentes na troca', () {
    final body = WearItemModel.encodeReplaceRequest(
      purchaseDate: DateTime(2026, 9, 20),
      installationDate: DateTime(2026, 9, 22),
    );

    expect(body, {
      'purchaseDate': '2026-09-20',
      'installationDate': '2026-09-22',
      'purchaseValue': null,
    });
  });
}
