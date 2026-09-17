import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/planned_items/domain/entities/planned_item.dart';
import 'package:olie/features/planned_items/domain/entities/planned_item_priority.dart';
import 'package:olie/features/planned_items/domain/usecases/add_planned_item.dart';
import 'package:olie/features/planned_items/domain/usecases/complete_planned_item.dart';
import 'package:olie/features/planned_items/domain/usecases/delete_planned_item.dart';
import 'package:olie/features/planned_items/domain/usecases/get_planned_items.dart';
import 'package:olie/features/planned_items/domain/usecases/update_planned_item.dart';
import 'package:olie/features/planned_items/presentation/bloc/planned_item_bloc.dart';

class MockGetPlannedItems extends Mock implements GetPlannedItems {}

class MockAddPlannedItem extends Mock implements AddPlannedItem {}

class MockUpdatePlannedItem extends Mock implements UpdatePlannedItem {}

class MockDeletePlannedItem extends Mock implements DeletePlannedItem {}

class MockCompletePlannedItem extends Mock implements CompletePlannedItem {}

void main() {
  late MockGetPlannedItems getPlannedItems;
  late MockAddPlannedItem addPlannedItem;
  late MockUpdatePlannedItem updatePlannedItem;
  late MockDeletePlannedItem deletePlannedItem;
  late MockCompletePlannedItem completePlannedItem;

  final item = PlannedItem(
    id: 'uuid',
    name: 'Trocar o notebook',
    priority: PlannedItemPriority.essential,
    estimatedValue: 4500,
    estimatedDate: DateTime(2026, 12, 1),
  );

  setUpAll(() {
    registerFallbackValue(
      AddPlannedItemParams(
        name: 'fallback',
        priority: PlannedItemPriority.essential,
        estimatedValue: 1,
        estimatedDate: DateTime(2026, 1, 1),
      ),
    );
    registerFallbackValue(
      UpdatePlannedItemParams(
        id: 'fallback',
        name: 'fallback',
        priority: PlannedItemPriority.essential,
        estimatedValue: 1,
        estimatedDate: DateTime(2026, 1, 1),
      ),
    );
    registerFallbackValue(const DeletePlannedItemParams('fallback'));
    registerFallbackValue(
      const CompletePlannedItemParams(
        id: 'fallback',
        paymentMethod: 'Pix',
      ),
    );
  });

  setUp(() {
    getPlannedItems = MockGetPlannedItems();
    addPlannedItem = MockAddPlannedItem();
    updatePlannedItem = MockUpdatePlannedItem();
    deletePlannedItem = MockDeletePlannedItem();
    completePlannedItem = MockCompletePlannedItem();
  });

  PlannedItemBloc buildBloc() => PlannedItemBloc(
        getPlannedItems: getPlannedItems,
        addPlannedItem: addPlannedItem,
        updatePlannedItem: updatePlannedItem,
        deletePlannedItem: deletePlannedItem,
        completePlannedItem: completePlannedItem,
      );

  blocTest<PlannedItemBloc, PlannedItemState>(
    'emite [loading, success] quando os itens são carregados',
    build: () {
      when(
        () => getPlannedItems(const NoParams()),
      ).thenAnswer((_) async => Right([item]));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const PlannedItemsRequested()),
    expect: () => [
      const PlannedItemState(status: PlannedItemStatus.loading),
      PlannedItemState(status: PlannedItemStatus.success, items: [item]),
    ],
  );

  blocTest<PlannedItemBloc, PlannedItemState>(
    'emite [failure] quando o carregamento falha',
    build: () {
      when(() => getPlannedItems(const NoParams())).thenAnswer(
        (_) async =>
            const Left(ServerFailure('Erro ao comunicar com o servidor.')),
      );
      return buildBloc();
    },
    act: (bloc) => bloc.add(const PlannedItemsRequested()),
    expect: () => [
      const PlannedItemState(status: PlannedItemStatus.loading),
      const PlannedItemState(
        status: PlannedItemStatus.failure,
        errorMessage: 'Erro ao comunicar com o servidor.',
      ),
    ],
  );

  blocTest<PlannedItemBloc, PlannedItemState>(
    'adiciona o item criado ao início da lista',
    build: () {
      when(() => addPlannedItem(any())).thenAnswer((_) async => Right(item));
      return buildBloc();
    },
    act: (bloc) => bloc.add(
      PlannedItemAdded(
        name: item.name,
        priority: item.priority,
        estimatedValue: item.estimatedValue,
        estimatedDate: item.estimatedDate,
      ),
    ),
    expect: () => [
      PlannedItemState(status: PlannedItemStatus.success, items: [item]),
    ],
  );

  blocTest<PlannedItemBloc, PlannedItemState>(
    'remove o item excluído da lista',
    seed: () => PlannedItemState(items: [item]),
    build: () {
      when(
        () => deletePlannedItem(any()),
      ).thenAnswer((_) async => const Right(null));
      return buildBloc();
    },
    act: (bloc) => bloc.add(PlannedItemDeleted(item.id)),
    expect: () => [
      const PlannedItemState(status: PlannedItemStatus.success, items: []),
    ],
  );

  blocTest<PlannedItemBloc, PlannedItemState>(
    'remove o item da lista ao efetivar a compra',
    seed: () => PlannedItemState(items: [item]),
    build: () {
      when(
        () => completePlannedItem(any()),
      ).thenAnswer((_) async => const Right(null));
      return buildBloc();
    },
    act: (bloc) => bloc.add(
      PlannedItemCompleted(id: item.id, paymentMethod: 'Pix'),
    ),
    expect: () => [
      const PlannedItemState(status: PlannedItemStatus.success, items: []),
    ],
  );
}
