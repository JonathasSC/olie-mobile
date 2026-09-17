import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/planned_items/domain/entities/planned_item.dart';
import 'package:olie/features/planned_items/domain/entities/planned_item_priority.dart';
import 'package:olie/features/planned_items/domain/usecases/add_planned_item.dart';
import 'package:olie/features/planned_items/domain/usecases/complete_planned_item.dart';
import 'package:olie/features/planned_items/domain/usecases/delete_planned_item.dart';
import 'package:olie/features/planned_items/domain/usecases/get_planned_items.dart';
import 'package:olie/features/planned_items/domain/usecases/update_planned_item.dart';

part 'planned_item_event.dart';
part 'planned_item_state.dart';

class PlannedItemBloc extends Bloc<PlannedItemEvent, PlannedItemState> {
  final GetPlannedItems getPlannedItems;
  final AddPlannedItem addPlannedItem;
  final UpdatePlannedItem updatePlannedItem;
  final DeletePlannedItem deletePlannedItem;
  final CompletePlannedItem completePlannedItem;

  PlannedItemBloc({
    required this.getPlannedItems,
    required this.addPlannedItem,
    required this.updatePlannedItem,
    required this.deletePlannedItem,
    required this.completePlannedItem,
  }) : super(const PlannedItemState()) {
    on<PlannedItemsRequested>(_onPlannedItemsRequested);
    on<PlannedItemAdded>(_onPlannedItemAdded);
    on<PlannedItemUpdated>(_onPlannedItemUpdated);
    on<PlannedItemDeleted>(_onPlannedItemDeleted);
    on<PlannedItemCompleted>(_onPlannedItemCompleted);
  }

  Future<void> _onPlannedItemsRequested(
    PlannedItemsRequested event,
    Emitter<PlannedItemState> emit,
  ) async {
    emit(state.copyWith(status: PlannedItemStatus.loading));

    final result = await getPlannedItems(const NoParams());

    result.fold(
      (failure) => emit(state.copyWith(
        status: PlannedItemStatus.failure,
        errorMessage: failure.message,
      )),
      (items) => emit(state.copyWith(
        status: PlannedItemStatus.success,
        items: items,
      )),
    );
  }

  Future<void> _onPlannedItemAdded(
    PlannedItemAdded event,
    Emitter<PlannedItemState> emit,
  ) async {
    final result = await addPlannedItem(
      AddPlannedItemParams(
        name: event.name,
        priority: event.priority,
        estimatedValue: event.estimatedValue,
        estimatedDate: event.estimatedDate,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: PlannedItemStatus.failure,
        errorMessage: failure.message,
      )),
      (item) => emit(state.copyWith(
        status: PlannedItemStatus.success,
        items: [item, ...state.items],
      )),
    );
  }

  Future<void> _onPlannedItemUpdated(
    PlannedItemUpdated event,
    Emitter<PlannedItemState> emit,
  ) async {
    final result = await updatePlannedItem(
      UpdatePlannedItemParams(
        id: event.id,
        name: event.name,
        priority: event.priority,
        estimatedValue: event.estimatedValue,
        estimatedDate: event.estimatedDate,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: PlannedItemStatus.failure,
        errorMessage: failure.message,
      )),
      (updated) => emit(state.copyWith(
        status: PlannedItemStatus.success,
        items: [
          for (final item in state.items)
            if (item.id == updated.id) updated else item,
        ],
      )),
    );
  }

  Future<void> _onPlannedItemDeleted(
    PlannedItemDeleted event,
    Emitter<PlannedItemState> emit,
  ) async {
    final result = await deletePlannedItem(DeletePlannedItemParams(event.id));

    result.fold(
      (failure) => emit(state.copyWith(
        status: PlannedItemStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: PlannedItemStatus.success,
        items: state.items.where((item) => item.id != event.id).toList(),
      )),
    );
  }

  Future<void> _onPlannedItemCompleted(
    PlannedItemCompleted event,
    Emitter<PlannedItemState> emit,
  ) async {
    final result = await completePlannedItem(
      CompletePlannedItemParams(
        id: event.id,
        paymentMethod: event.paymentMethod,
        value: event.value,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: PlannedItemStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: PlannedItemStatus.success,
        items: state.items.where((item) => item.id != event.id).toList(),
      )),
    );
  }
}
