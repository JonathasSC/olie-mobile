import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/features/wear_items/domain/entities/lifespan_unit.dart';
import 'package:olie/features/wear_items/domain/entities/wear_cycle.dart';
import 'package:olie/features/wear_items/domain/entities/wear_estimate.dart';
import 'package:olie/features/wear_items/domain/entities/wear_estimate_source.dart';
import 'package:olie/features/wear_items/domain/entities/wear_item.dart';
import 'package:olie/features/wear_items/domain/entities/wear_item_detail.dart';
import 'package:olie/features/wear_items/domain/entities/wear_status.dart';
import 'package:olie/features/wear_items/domain/usecases/add_wear_item.dart';
import 'package:olie/features/wear_items/domain/usecases/delete_wear_item.dart';
import 'package:olie/features/wear_items/domain/usecases/get_wear_item_detail.dart';
import 'package:olie/features/wear_items/domain/usecases/get_wear_items.dart';
import 'package:olie/features/wear_items/domain/usecases/replace_wear_item.dart';
import 'package:olie/features/wear_items/domain/usecases/update_wear_item.dart';
import 'package:olie/features/wear_items/presentation/bloc/wear_item_bloc.dart';

class MockGetWearItems extends Mock implements GetWearItems {}

class MockGetWearItemDetail extends Mock implements GetWearItemDetail {}

class MockAddWearItem extends Mock implements AddWearItem {}

class MockUpdateWearItem extends Mock implements UpdateWearItem {}

class MockDeleteWearItem extends Mock implements DeleteWearItem {}

class MockReplaceWearItem extends Mock implements ReplaceWearItem {}

WearItem buildItem({
  required String id,
  DateTime? replacementDate,
  WearStatus status = WearStatus.ok,
}) {
  return WearItem(
    id: id,
    name: 'Item $id',
    expectedLifespan: 6,
    expectedLifespanUnit: LifespanUnit.months,
    currentCycle: WearCycle(
      id: 'cycle-$id',
      purchaseDate: DateTime(2026, 3, 10),
      installationDate: replacementDate == null ? null : DateTime(2026, 3, 15),
    ),
    estimate: WearEstimate(
      lifespanDays: 180,
      source: WearEstimateSource.expected,
      estimatedReplacementDate: replacementDate,
      status: status,
    ),
    cyclesCount: 1,
    createdAt: DateTime.utc(2026, 3, 10),
  );
}

void main() {
  late MockGetWearItems getWearItems;
  late MockGetWearItemDetail getWearItemDetail;
  late MockAddWearItem addWearItem;
  late MockUpdateWearItem updateWearItem;
  late MockDeleteWearItem deleteWearItem;
  late MockReplaceWearItem replaceWearItem;

  final soon = buildItem(id: 'soon', replacementDate: DateTime(2026, 10, 1));
  final later = buildItem(id: 'later', replacementDate: DateTime(2026, 12, 1));
  final inStock = buildItem(id: 'stock', status: WearStatus.inStock);
  final oldCycle = WearCycle(
    id: 'old',
    purchaseDate: DateTime(2025, 9, 1),
    installationDate: DateTime(2025, 9, 2),
    removalDate: DateTime(2026, 3, 15),
    lifespanDays: 194,
  );

  setUpAll(() {
    registerFallbackValue(const GetWearItemsParams());
    registerFallbackValue(const GetWearItemDetailParams('fallback'));
    registerFallbackValue(
      AddWearItemParams(
        name: 'fallback',
        expectedLifespan: 1,
        expectedLifespanUnit: LifespanUnit.days,
        purchaseDate: DateTime(2026, 1, 1),
      ),
    );
    registerFallbackValue(const DeleteWearItemParams('fallback'));
    registerFallbackValue(
      ReplaceWearItemParams(id: 'fallback', purchaseDate: DateTime(2026, 1, 1)),
    );
  });

  setUp(() {
    getWearItems = MockGetWearItems();
    getWearItemDetail = MockGetWearItemDetail();
    addWearItem = MockAddWearItem();
    updateWearItem = MockUpdateWearItem();
    deleteWearItem = MockDeleteWearItem();
    replaceWearItem = MockReplaceWearItem();
  });

  WearItemBloc buildBloc() => WearItemBloc(
    getWearItems: getWearItems,
    getWearItemDetail: getWearItemDetail,
    addWearItem: addWearItem,
    updateWearItem: updateWearItem,
    deleteWearItem: deleteWearItem,
    replaceWearItem: replaceWearItem,
  );

  blocTest<WearItemBloc, WearItemState>(
    'emite [loading, success] quando os itens são carregados',
    build: () {
      when(
        () => getWearItems(any()),
      ).thenAnswer((_) async => Right([soon, later]));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const WearItemsRequested()),
    expect: () => [
      const WearItemState(status: WearItemStatus.loading),
      WearItemState(status: WearItemStatus.success, items: [soon, later]),
    ],
  );

  blocTest<WearItemBloc, WearItemState>(
    'repassa o filtro de status para o caso de uso',
    build: () {
      when(() => getWearItems(any())).thenAnswer((_) async => Right([soon]));
      return buildBloc();
    },
    act: (bloc) => bloc.add(
      const WearItemsRequested(statuses: {WearStatus.overdue}),
    ),
    expect: () => [
      const WearItemState(
        status: WearItemStatus.loading,
        statusFilter: {WearStatus.overdue},
      ),
      WearItemState(
        status: WearItemStatus.success,
        items: [soon],
        statusFilter: const {WearStatus.overdue},
      ),
    ],
    verify: (_) => verify(
      () => getWearItems(
        const GetWearItemsParams(statuses: {WearStatus.overdue}),
      ),
    ).called(1),
  );

  blocTest<WearItemBloc, WearItemState>(
    'emite [failure] quando o carregamento falha',
    build: () {
      when(() => getWearItems(any())).thenAnswer(
        (_) async =>
            const Left(ServerFailure('Erro ao comunicar com o servidor.')),
      );
      return buildBloc();
    },
    act: (bloc) => bloc.add(const WearItemsRequested()),
    expect: () => [
      const WearItemState(status: WearItemStatus.loading),
      const WearItemState(
        status: WearItemStatus.failure,
        errorMessage: 'Erro ao comunicar com o servidor.',
      ),
    ],
  );

  blocTest<WearItemBloc, WearItemState>(
    'insere o item criado respeitando a ordem da troca (estoque ao final)',
    seed: () => WearItemState(items: [later, inStock]),
    build: () {
      when(() => addWearItem(any())).thenAnswer((_) async => Right(soon));
      return buildBloc();
    },
    act: (bloc) => bloc.add(
      WearItemAdded(
        name: soon.name,
        expectedLifespan: 6,
        expectedLifespanUnit: LifespanUnit.months,
        purchaseDate: DateTime(2026, 3, 10),
      ),
    ),
    expect: () => [
      WearItemState(
        status: WearItemStatus.success,
        items: [soon, later, inStock],
      ),
    ],
  );

  blocTest<WearItemBloc, WearItemState>(
    'carrega o histórico de um item',
    seed: () => WearItemState(items: [soon]),
    build: () {
      when(() => getWearItemDetail(any())).thenAnswer(
        (_) async => Right(WearItemDetail(item: soon, history: [oldCycle])),
      );
      return buildBloc();
    },
    act: (bloc) => bloc.add(WearItemHistoryRequested(soon.id)),
    expect: () => [
      WearItemState(
        status: WearItemStatus.success,
        items: [soon],
        histories: {
          soon.id: [oldCycle],
        },
      ),
    ],
  );

  blocTest<WearItemBloc, WearItemState>(
    'atualiza o item e descarta o histórico em cache ao registrar a troca',
    seed: () => WearItemState(
      items: [soon, later],
      histories: {
        soon.id: [oldCycle],
      },
    ),
    build: () {
      final replaced = buildItem(
        id: soon.id,
        replacementDate: DateTime(2027, 3, 1),
      );
      when(
        () => replaceWearItem(any()),
      ).thenAnswer((_) async => Right(replaced));
      return buildBloc();
    },
    act: (bloc) => bloc.add(
      WearItemReplaced(id: soon.id, purchaseDate: DateTime(2026, 9, 20)),
    ),
    expect: () => [
      WearItemState(
        status: WearItemStatus.success,
        items: [
          later,
          buildItem(id: soon.id, replacementDate: DateTime(2027, 3, 1)),
        ],
      ),
    ],
  );

  blocTest<WearItemBloc, WearItemState>(
    'remove o item excluído da lista',
    seed: () => WearItemState(items: [soon]),
    build: () {
      when(
        () => deleteWearItem(any()),
      ).thenAnswer((_) async => const Right(null));
      return buildBloc();
    },
    act: (bloc) => bloc.add(WearItemDeleted(soon.id)),
    expect: () => [
      const WearItemState(status: WearItemStatus.success, items: []),
    ],
  );
}
