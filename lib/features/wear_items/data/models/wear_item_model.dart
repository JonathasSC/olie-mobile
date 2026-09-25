import 'package:olie/features/wear_items/domain/entities/lifespan_unit.dart';
import 'package:olie/features/wear_items/domain/entities/wear_cycle.dart';
import 'package:olie/features/wear_items/domain/entities/wear_estimate.dart';
import 'package:olie/features/wear_items/domain/entities/wear_estimate_source.dart';
import 'package:olie/features/wear_items/domain/entities/wear_item.dart';
import 'package:olie/features/wear_items/domain/entities/wear_item_detail.dart';
import 'package:olie/features/wear_items/domain/entities/wear_status.dart';

class WearItemModel extends WearItem {
  const WearItemModel({
    required super.id,
    required super.name,
    super.categoryId,
    required super.expectedLifespan,
    required super.expectedLifespanUnit,
    required super.currentCycle,
    required super.estimate,
    required super.cyclesCount,
    required super.createdAt,
  });

  factory WearItemModel.fromJson(Map<String, dynamic> json) {
    return WearItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      categoryId: json['categoryId'] as String?,
      expectedLifespan: (json['expectedLifespan'] as num).toInt(),
      expectedLifespanUnit: LifespanUnit.fromApiValue(
        json['expectedLifespanUnit'] as String,
      ),
      currentCycle: cycleFromJson(json['currentCycle'] as Map<String, dynamic>),
      estimate: _estimateFromJson(json['estimate'] as Map<String, dynamic>),
      cyclesCount: (json['cyclesCount'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static WearItemDetail detailFromJson(Map<String, dynamic> json) {
    final history = (json['history'] as List<dynamic>? ?? const [])
        .map((cycle) => cycleFromJson(cycle as Map<String, dynamic>))
        .toList();
    return WearItemDetail(
      item: WearItemModel.fromJson(json),
      history: history,
    );
  }

  static WearCycle cycleFromJson(Map<String, dynamic> json) {
    return WearCycle(
      id: json['id'] as String,
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
      installationDate: _parseDate(json['installationDate']),
      removalDate: _parseDate(json['removalDate']),
      purchaseValue: (json['purchaseValue'] as num?)?.toDouble(),
      lifespanDays: (json['lifespanDays'] as num?)?.toInt(),
    );
  }

  static WearEstimate _estimateFromJson(Map<String, dynamic> json) {
    return WearEstimate(
      lifespanDays: (json['lifespanDays'] as num).toInt(),
      source: WearEstimateSource.fromApiValue(json['source'] as String),
      estimatedReplacementDate: _parseDate(json['estimatedReplacementDate']),
      daysRemaining: (json['daysRemaining'] as num?)?.toInt(),
      wearPercentage: (json['wearPercentage'] as num?)?.toInt(),
      status: WearStatus.fromApiValue(json['status'] as String),
      suggestedValue: (json['suggestedValue'] as num?)?.toDouble(),
    );
  }

  static Map<String, dynamic> encodeRequest({
    required String name,
    required int expectedLifespan,
    required LifespanUnit expectedLifespanUnit,
    required DateTime purchaseDate,
    DateTime? installationDate,
    double? purchaseValue,
    String? categoryId,
  }) {
    return {
      'name': name,
      'categoryId': categoryId,
      'expectedLifespan': expectedLifespan,
      'expectedLifespanUnit': expectedLifespanUnit.apiValue,
      'purchaseDate': formatDate(purchaseDate),
      'installationDate': installationDate == null
          ? null
          : formatDate(installationDate),
      'purchaseValue': purchaseValue,
    };
  }

  static Map<String, dynamic> encodeReplaceRequest({
    required DateTime purchaseDate,
    DateTime? installationDate,
    DateTime? removalDate,
    double? purchaseValue,
    String? paymentMethod,
  }) {
    return {
      'purchaseDate': formatDate(purchaseDate),
      'installationDate': installationDate == null
          ? null
          : formatDate(installationDate),
      // Omitido: a API usa a instalação da nova unidade ou a data de hoje.
      'removalDate': ?(removalDate == null ? null : formatDate(removalDate)),
      'purchaseValue': purchaseValue,
      'paymentMethod': ?paymentMethod,
    };
  }

  static DateTime? _parseDate(Object? value) =>
      value == null ? null : DateTime.parse(value as String);

  static String formatDate(DateTime date) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${date.year}-${twoDigits(date.month)}-${twoDigits(date.day)}';
  }
}
