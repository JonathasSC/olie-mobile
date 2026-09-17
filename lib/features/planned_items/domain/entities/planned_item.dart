import 'package:equatable/equatable.dart';

import 'package:olie/features/planned_items/domain/entities/planned_item_priority.dart';

class PlannedItem extends Equatable {
  final String id;
  final String name;
  final PlannedItemPriority priority;
  final double estimatedValue;
  final DateTime estimatedDate;
  final String? categoryId;

  const PlannedItem({
    required this.id,
    required this.name,
    required this.priority,
    required this.estimatedValue,
    required this.estimatedDate,
    this.categoryId,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    priority,
    estimatedValue,
    estimatedDate,
    categoryId,
  ];
}
