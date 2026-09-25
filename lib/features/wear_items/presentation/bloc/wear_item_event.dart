part of 'wear_item_bloc.dart';

abstract class WearItemEvent extends Equatable {
  const WearItemEvent();

  @override
  List<Object?> get props => [];
}

class WearItemsRequested extends WearItemEvent {
  /// Novo filtro de status; `null` mantém o filtro atual.
  final Set<WearStatus>? statuses;

  const WearItemsRequested({this.statuses});

  @override
  List<Object?> get props => [statuses];
}

class WearItemHistoryRequested extends WearItemEvent {
  final String id;

  const WearItemHistoryRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class WearItemAdded extends WearItemEvent {
  final String name;
  final int expectedLifespan;
  final LifespanUnit expectedLifespanUnit;
  final DateTime purchaseDate;
  final DateTime? installationDate;
  final double? purchaseValue;

  const WearItemAdded({
    required this.name,
    required this.expectedLifespan,
    required this.expectedLifespanUnit,
    required this.purchaseDate,
    this.installationDate,
    this.purchaseValue,
  });

  @override
  List<Object?> get props => [
    name,
    expectedLifespan,
    expectedLifespanUnit,
    purchaseDate,
    installationDate,
    purchaseValue,
  ];
}

class WearItemUpdated extends WearItemEvent {
  final String id;
  final String name;
  final int expectedLifespan;
  final LifespanUnit expectedLifespanUnit;
  final DateTime purchaseDate;
  final DateTime? installationDate;
  final double? purchaseValue;

  const WearItemUpdated({
    required this.id,
    required this.name,
    required this.expectedLifespan,
    required this.expectedLifespanUnit,
    required this.purchaseDate,
    this.installationDate,
    this.purchaseValue,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    expectedLifespan,
    expectedLifespanUnit,
    purchaseDate,
    installationDate,
    purchaseValue,
  ];
}

class WearItemDeleted extends WearItemEvent {
  final String id;

  const WearItemDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

class WearItemReplaced extends WearItemEvent {
  final String id;
  final DateTime purchaseDate;
  final DateTime? installationDate;
  final DateTime? removalDate;
  final double? purchaseValue;
  final String? paymentMethod;

  const WearItemReplaced({
    required this.id,
    required this.purchaseDate,
    this.installationDate,
    this.removalDate,
    this.purchaseValue,
    this.paymentMethod,
  });

  @override
  List<Object?> get props => [
    id,
    purchaseDate,
    installationDate,
    removalDate,
    purchaseValue,
    paymentMethod,
  ];
}
