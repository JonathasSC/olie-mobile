import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/features/contacts/domain/entities/contact.dart';
import 'package:olie/features/contacts/domain/entities/phone_number.dart';
import 'package:olie/features/contacts/domain/repositories/contact_repository.dart';
import 'package:olie/features/contacts/domain/usecases/add_contact.dart';

class MockContactRepository extends Mock implements ContactRepository {}

void main() {
  late MockContactRepository repository;
  late AddContact addContact;

  final contact = Contact(
    id: 'k1',
    name: 'Farmácia Central',
    phone: '+5511999999999',
    categoryIds: const ['c1'],
    active: true,
    doNotContact: false,
    contactable: true,
    createdAt: DateTime.utc(2026, 9, 28),
  );

  setUp(() {
    repository = MockContactRepository();
    addContact = AddContact(repository);
  });

  group('normalizePhone', () {
    test('aceita a formatação usual e devolve E.164', () {
      expect(normalizePhone('+55 (11) 99999-9999'), '+5511999999999');
      expect(normalizePhone(' +55.11.3333.4444 '), '+551133334444');
    });

    test('recusa número sem código do país ou curto demais', () {
      expect(normalizePhone('11999999999'), isNull);
      expect(normalizePhone('+55 11 999'), isNull);
      expect(normalizePhone('+0511999999999'), isNull);
    });
  });

  test('envia o telefone normalizado e o nome sem espaços', () async {
    when(
      () => repository.addContact(
        name: any(named: 'name'),
        phone: any(named: 'phone'),
        categoryIds: any(named: 'categoryIds'),
        active: any(named: 'active'),
        doNotContact: any(named: 'doNotContact'),
      ),
    ).thenAnswer((_) async => Right(contact));

    final result = await addContact(
      const AddContactParams(
        name: '  Farmácia Central ',
        phone: '+55 (11) 99999-9999',
        categoryIds: {'c1'},
      ),
    );

    expect(result, Right<Failure, Contact>(contact));
    verify(
      () => repository.addContact(
        name: 'Farmácia Central',
        phone: '+5511999999999',
        categoryIds: {'c1'},
        active: true,
        doNotContact: false,
      ),
    ).called(1);
  });

  test('recusa telefone inválido sem chamar a API', () async {
    final result = await addContact(
      const AddContactParams(
        name: 'X',
        phone: '11 99999-9999',
        categoryIds: {'c1'},
      ),
    );

    expect(result.isLeft(), isTrue);
    verifyZeroInteractions(repository);
  });

  test('exige ao menos uma categoria', () async {
    final result = await addContact(
      const AddContactParams(
        name: 'X',
        phone: '+5511999999999',
        categoryIds: {},
      ),
    );

    expect(
      result,
      const Left<Failure, Contact>(
        ValidationFailure('Escolha ao menos uma categoria.'),
      ),
    );
  });
}
