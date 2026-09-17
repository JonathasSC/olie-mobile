import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/planned_items/domain/entities/planned_item.dart';
import 'package:olie/features/planned_items/domain/entities/planned_item_priority.dart';
import 'package:olie/features/planned_items/domain/repositories/planned_item_repository.dart';
import 'package:olie/features/planned_items/domain/usecases/get_planned_items.dart';

class MockPlannedItemRepository extends Mock
    implements PlannedItemRepository {}

void main() {
  late MockPlannedItemRepository repository;
  late GetPlannedItems usecase;

  setUp(() {
    repository = MockPlannedItemRepository();
    usecase = GetPlannedItems(repository);
  });

  final items = [
    PlannedItem(
      id: 'uuid',
      name: 'Trocar o notebook',
      priority: PlannedItemPriority.essential,
      estimatedValue: 4500,
      estimatedDate: DateTime(2026, 12, 1),
    ),
  ];

  test(
    'deve retornar a lista de itens planejados quando o repositório é bem-sucedido',
    () async {
      when(
        () => repository.getPlannedItems(),
      ).thenAnswer((_) async => Right(items));

      final result = await usecase(const NoParams());

      expect(result, Right(items));
      verify(() => repository.getPlannedItems()).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
