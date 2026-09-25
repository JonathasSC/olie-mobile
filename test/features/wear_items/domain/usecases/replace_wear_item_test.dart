import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/features/wear_items/domain/repositories/wear_item_repository.dart';
import 'package:olie/features/wear_items/domain/usecases/replace_wear_item.dart';

class MockWearItemRepository extends Mock implements WearItemRepository {}

void main() {
  late MockWearItemRepository repository;
  late ReplaceWearItem usecase;

  setUp(() {
    repository = MockWearItemRepository();
    usecase = ReplaceWearItem(repository);
  });

  test(
    'deve falhar sem chamar a API quando há forma de pagamento sem valor',
    () async {
      final result = await usecase(
        ReplaceWearItemParams(
          id: 'uuid',
          purchaseDate: DateTime(2026, 9, 20),
          paymentMethod: 'Pix',
        ),
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('deveria falhar'),
      );
      verifyZeroInteractions(repository);
    },
  );

  test('deve repassar a troca ao repositório', () async {
    when(
      () => repository.replaceWearItem(
        id: any(named: 'id'),
        purchaseDate: any(named: 'purchaseDate'),
        installationDate: any(named: 'installationDate'),
        removalDate: any(named: 'removalDate'),
        purchaseValue: any(named: 'purchaseValue'),
        paymentMethod: any(named: 'paymentMethod'),
      ),
    ).thenAnswer((_) async => const Left(ServerFailure()));

    await usecase(
      ReplaceWearItemParams(
        id: 'uuid',
        purchaseDate: DateTime(2026, 9, 20),
        purchaseValue: 94.90,
        paymentMethod: 'Pix',
      ),
    );

    verify(
      () => repository.replaceWearItem(
        id: 'uuid',
        purchaseDate: DateTime(2026, 9, 20),
        purchaseValue: 94.90,
        paymentMethod: 'Pix',
      ),
    ).called(1);
  });
}
