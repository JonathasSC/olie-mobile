part of 'wear_item_bloc.dart';

enum WearItemStatus { initial, loading, success, failure }

class WearItemState extends Equatable {
  final WearItemStatus status;
  final List<WearItem> items;
  final Set<WearStatus> statusFilter;

  /// Histórico de ciclos já carregado, por id do item.
  final Map<String, List<WearCycle>> histories;
  final String? errorMessage;

  const WearItemState({
    this.status = WearItemStatus.initial,
    this.items = const [],
    this.statusFilter = const {},
    this.histories = const {},
    this.errorMessage,
  });

  WearItemState copyWith({
    WearItemStatus? status,
    List<WearItem>? items,
    Set<WearStatus>? statusFilter,
    Map<String, List<WearCycle>>? histories,
    String? errorMessage,
  }) {
    return WearItemState(
      status: status ?? this.status,
      items: items ?? this.items,
      statusFilter: statusFilter ?? this.statusFilter,
      histories: histories ?? this.histories,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    statusFilter,
    histories,
    errorMessage,
  ];
}
