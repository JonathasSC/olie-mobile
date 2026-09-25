import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:olie/features/wear_items/domain/entities/lifespan_unit.dart';
import 'package:olie/features/wear_items/domain/entities/wear_cycle.dart';
import 'package:olie/features/wear_items/domain/entities/wear_item.dart';
import 'package:olie/features/wear_items/domain/entities/wear_status.dart';
import 'package:olie/features/wear_items/domain/usecases/add_wear_item.dart';
import 'package:olie/features/wear_items/domain/usecases/delete_wear_item.dart';
import 'package:olie/features/wear_items/domain/usecases/get_wear_item_detail.dart';
import 'package:olie/features/wear_items/domain/usecases/get_wear_items.dart';
import 'package:olie/features/wear_items/domain/usecases/replace_wear_item.dart';
import 'package:olie/features/wear_items/domain/usecases/update_wear_item.dart';

part 'wear_item_event.dart';
part 'wear_item_state.dart';

class WearItemBloc extends Bloc<WearItemEvent, WearItemState> {
  final GetWearItems getWearItems;
  final GetWearItemDetail getWearItemDetail;
  final AddWearItem addWearItem;
  final UpdateWearItem updateWearItem;
  final DeleteWearItem deleteWearItem;
  final ReplaceWearItem replaceWearItem;

  WearItemBloc({
    required this.getWearItems,
    required this.getWearItemDetail,
    required this.addWearItem,
    required this.updateWearItem,
    required this.deleteWearItem,
    required this.replaceWearItem,
  }) : super(const WearItemState()) {
    on<WearItemsRequested>(_onWearItemsRequested);
    on<WearItemHistoryRequested>(_onWearItemHistoryRequested);
    on<WearItemAdded>(_onWearItemAdded);
    on<WearItemUpdated>(_onWearItemUpdated);
    on<WearItemDeleted>(_onWearItemDeleted);
    on<WearItemReplaced>(_onWearItemReplaced);
  }

  Future<void> _onWearItemsRequested(
    WearItemsRequested event,
    Emitter<WearItemState> emit,
  ) async {
    final statusFilter = event.statuses ?? state.statusFilter;
    emit(state.copyWith(
      status: WearItemStatus.loading,
      statusFilter: statusFilter,
    ));

    final result = await getWearItems(
      GetWearItemsParams(statuses: statusFilter),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: WearItemStatus.failure,
        errorMessage: failure.message,
      )),
      (items) => emit(state.copyWith(
        status: WearItemStatus.success,
        items: items,
      )),
    );
  }

  Future<void> _onWearItemHistoryRequested(
    WearItemHistoryRequested event,
    Emitter<WearItemState> emit,
  ) async {
    final result = await getWearItemDetail(GetWearItemDetailParams(event.id));

    result.fold(
      (failure) => emit(state.copyWith(
        status: WearItemStatus.failure,
        errorMessage: failure.message,
      )),
      (detail) => emit(state.copyWith(
        status: WearItemStatus.success,
        items: _upsert(state.items, detail.item),
        histories: {...state.histories, event.id: detail.history},
      )),
    );
  }

  Future<void> _onWearItemAdded(
    WearItemAdded event,
    Emitter<WearItemState> emit,
  ) async {
    final result = await addWearItem(
      AddWearItemParams(
        name: event.name,
        expectedLifespan: event.expectedLifespan,
        expectedLifespanUnit: event.expectedLifespanUnit,
        purchaseDate: event.purchaseDate,
        installationDate: event.installationDate,
        purchaseValue: event.purchaseValue,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: WearItemStatus.failure,
        errorMessage: failure.message,
      )),
      (item) => emit(state.copyWith(
        status: WearItemStatus.success,
        items: _upsert(state.items, item),
      )),
    );
  }

  Future<void> _onWearItemUpdated(
    WearItemUpdated event,
    Emitter<WearItemState> emit,
  ) async {
    final result = await updateWearItem(
      UpdateWearItemParams(
        id: event.id,
        name: event.name,
        expectedLifespan: event.expectedLifespan,
        expectedLifespanUnit: event.expectedLifespanUnit,
        purchaseDate: event.purchaseDate,
        installationDate: event.installationDate,
        purchaseValue: event.purchaseValue,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: WearItemStatus.failure,
        errorMessage: failure.message,
      )),
      (item) => emit(state.copyWith(
        status: WearItemStatus.success,
        items: _upsert(state.items, item),
      )),
    );
  }

  Future<void> _onWearItemDeleted(
    WearItemDeleted event,
    Emitter<WearItemState> emit,
  ) async {
    final result = await deleteWearItem(DeleteWearItemParams(event.id));

    result.fold(
      (failure) => emit(state.copyWith(
        status: WearItemStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: WearItemStatus.success,
        items: state.items.where((item) => item.id != event.id).toList(),
        histories: Map.of(state.histories)..remove(event.id),
      )),
    );
  }

  Future<void> _onWearItemReplaced(
    WearItemReplaced event,
    Emitter<WearItemState> emit,
  ) async {
    final result = await replaceWearItem(
      ReplaceWearItemParams(
        id: event.id,
        purchaseDate: event.purchaseDate,
        installationDate: event.installationDate,
        removalDate: event.removalDate,
        purchaseValue: event.purchaseValue,
        paymentMethod: event.paymentMethod,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: WearItemStatus.failure,
        errorMessage: failure.message,
      )),
      (item) => emit(state.copyWith(
        status: WearItemStatus.success,
        items: _upsert(state.items, item),
        // O ciclo encerrado entrou no histórico: descarta o cache para que
        // seja recarregado na próxima vez que o histórico for aberto.
        histories: Map.of(state.histories)..remove(event.id),
      )),
    );
  }

  /// Insere/substitui [item] mantendo a ordem da API (troca mais próxima
  /// primeiro, itens em estoque ao final) e respeitando o filtro ativo.
  List<WearItem> _upsert(List<WearItem> items, WearItem item) {
    final filter = state.statusFilter;
    final next = [
      for (final current in items)
        if (current.id != item.id) current,
      if (filter.isEmpty || filter.contains(item.estimate.status)) item,
    ];
    next.sort((a, b) {
      final aDate = a.estimate.estimatedReplacementDate;
      final bDate = b.estimate.estimatedReplacementDate;
      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return aDate.compareTo(bDate);
    });
    return next;
  }
}
