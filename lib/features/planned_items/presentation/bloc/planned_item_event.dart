part of 'planned_item_bloc.dart';

abstract class PlannedItemEvent extends Equatable {
  const PlannedItemEvent();

  @override
  List<Object?> get props => [];
}

class PlannedItemsRequested extends PlannedItemEvent {
  const PlannedItemsRequested();
}

class PlannedItemAdded extends PlannedItemEvent {
  final String name;
  final PlannedItemPriority priority;
  final double estimatedValue;
  final DateTime estimatedDate;

  const PlannedItemAdded({
    required this.name,
    required this.priority,
    required this.estimatedValue,
    required this.estimatedDate,
  });

  @override
  List<Object?> get props => [name, priority, estimatedValue, estimatedDate];
}

class PlannedItemUpdated extends PlannedItemEvent {
  final String id;
  final String name;
  final PlannedItemPriority priority;
  final double estimatedValue;
  final DateTime estimatedDate;

  const PlannedItemUpdated({
    required this.id,
    required this.name,
    required this.priority,
    required this.estimatedValue,
    required this.estimatedDate,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    priority,
    estimatedValue,
    estimatedDate,
  ];
}

class PlannedItemDeleted extends PlannedItemEvent {
  final String id;

  const PlannedItemDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

class PlannedItemCompleted extends PlannedItemEvent {
  final String id;
  final String paymentMethod;
  final double? value;

  const PlannedItemCompleted({
    required this.id,
    required this.paymentMethod,
    this.value,
  });

  @override
  List<Object?> get props => [id, paymentMethod, value];
}
