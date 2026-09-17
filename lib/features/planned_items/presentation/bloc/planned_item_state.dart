part of 'planned_item_bloc.dart';

enum PlannedItemStatus { initial, loading, success, failure }

class PlannedItemState extends Equatable {
  final PlannedItemStatus status;
  final List<PlannedItem> items;
  final String? errorMessage;

  const PlannedItemState({
    this.status = PlannedItemStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  PlannedItemState copyWith({
    PlannedItemStatus? status,
    List<PlannedItem>? items,
    String? errorMessage,
  }) {
    return PlannedItemState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
