import 'package:equatable/equatable.dart';

/// Uma unidade do item: a atual (sem [removalDate]) ou uma já substituída,
/// vinda do histórico.
class WearCycle extends Equatable {
  final String id;
  final DateTime purchaseDate;

  /// `null` enquanto a unidade estiver comprada mas ainda não instalada.
  final DateTime? installationDate;
  final DateTime? removalDate;
  final double? purchaseValue;

  /// Duração real do ciclo — só presente nos ciclos do histórico.
  final int? lifespanDays;

  const WearCycle({
    required this.id,
    required this.purchaseDate,
    this.installationDate,
    this.removalDate,
    this.purchaseValue,
    this.lifespanDays,
  });

  @override
  List<Object?> get props => [
    id,
    purchaseDate,
    installationDate,
    removalDate,
    purchaseValue,
    lifespanDays,
  ];
}
