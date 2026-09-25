import 'package:equatable/equatable.dart';

import 'package:olie/features/wear_items/domain/entities/wear_estimate_source.dart';
import 'package:olie/features/wear_items/domain/entities/wear_status.dart';

/// Estimativa de recompra calculada pelo backend a cada leitura.
///
/// [estimatedReplacementDate], [daysRemaining] e [wearPercentage] são `null`
/// quando o ciclo atual ainda não foi instalado ([WearStatus.inStock]).
class WearEstimate extends Equatable {
  final int lifespanDays;
  final WearEstimateSource source;
  final DateTime? estimatedReplacementDate;
  final int? daysRemaining;
  final int? wearPercentage;
  final WearStatus status;
  final double? suggestedValue;

  const WearEstimate({
    required this.lifespanDays,
    required this.source,
    this.estimatedReplacementDate,
    this.daysRemaining,
    this.wearPercentage,
    required this.status,
    this.suggestedValue,
  });

  @override
  List<Object?> get props => [
    lifespanDays,
    source,
    estimatedReplacementDate,
    daysRemaining,
    wearPercentage,
    status,
    suggestedValue,
  ];
}
