import 'package:equatable/equatable.dart';

import 'package:olie/features/wear_items/domain/entities/lifespan_unit.dart';
import 'package:olie/features/wear_items/domain/entities/wear_cycle.dart';
import 'package:olie/features/wear_items/domain/entities/wear_estimate.dart';

class WearItem extends Equatable {
  final String id;
  final String name;
  final String? categoryId;
  final int expectedLifespan;
  final LifespanUnit expectedLifespanUnit;
  final WearCycle currentCycle;
  final WearEstimate estimate;
  final int cyclesCount;
  final DateTime createdAt;

  const WearItem({
    required this.id,
    required this.name,
    this.categoryId,
    required this.expectedLifespan,
    required this.expectedLifespanUnit,
    required this.currentCycle,
    required this.estimate,
    required this.cyclesCount,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    categoryId,
    expectedLifespan,
    expectedLifespanUnit,
    currentCycle,
    estimate,
    cyclesCount,
    createdAt,
  ];
}
