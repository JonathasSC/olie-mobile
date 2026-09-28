import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/contacts/domain/entities/contact.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry_status.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry_support.dart';
import 'package:olie/features/inquiries/domain/usecases/create_inquiry.dart';
import 'package:olie/features/inquiries/domain/usecases/get_inquiry_draft.dart';
import 'package:olie/features/inquiries/domain/usecases/get_inquiry_settings.dart';
import 'package:olie/features/inquiries/domain/usecases/inquiry_id_params.dart';
import 'package:olie/features/inquiries/domain/usecases/preview_inquiry.dart';
import 'package:olie/features/inquiries/domain/usecases/upload_inquiry_photo.dart';
import 'package:olie/features/inquiries/presentation/bloc/inquiry_composer_bloc.dart';

class MockGetInquirySettings extends Mock implements GetInquirySettings {}

class MockGetInquiryDraft extends Mock implements GetInquiryDraft {}

class MockUploadInquiryPhoto extends Mock implements UploadInquiryPhoto {}

class MockPreviewInquiry extends Mock implements PreviewInquiry {}

class MockCreateInquiry extends Mock implements CreateInquiry {}

Contact contact(
  String id,
  List<String> categories, {
  bool contactable = true,
}) => Contact(
  id: id,
  name: 'Contato $id',
  phone: '+55119000000$id',
  categoryIds: categories,
  active: contactable,
  doNotContact: false,
  contactable: contactable,
  createdAt: DateTime.utc(2026, 9, 28),
);

const settings = InquirySettings(
  messageTemplate: '{saudacao}! {pergunta}\n\n{itens}',
  timezone: 'America/Sao_Paulo',
  maxItems: 10,
  maxRecipients: 30,
  contactIntervalMinSeconds: 20,
  contactIntervalMaxSeconds: 60,
  duplicateWindowHours: 168,
  maxPhotoUploadBytes: 10485760,
);

void main() {
  late MockGetInquirySettings getSettings;
  late MockGetInquiryDraft getDraft;
  late MockUploadInquiryPhoto uploadPhoto;
  late MockPreviewInquiry preview;
  late MockCreateInquiry create;

  // Farmácias (c1): 1, 2 e 3 (inativo); Mercados (c2): 4.
  final contacts = [
    contact('1', ['c1']),
    contact('2', ['c1', 'c2']),
    contact('3', ['c1'], contactable: false),
    contact('4', ['c2']),
  ];

  final created = Inquiry(
    id: 'q1',
    status: InquiryStatus.sending,
    simulated: false,
    items: const [],
    totals: const InquiryTotals(total: 1, pending: 1),
    startedAt: DateTime.utc(2026, 9, 28),
    createdAt: DateTime.utc(2026, 9, 28),
  );

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const InquiryIdParams('x'));
    registerFallbackValue(
      const CreateInquiryParams(contactIds: [], items: []),
    );
    registerFallbackValue(
      UploadInquiryPhotoParams(bytes: Uint8List(0), fileName: 'x'),
    );
  });

  setUp(() {
    getSettings = MockGetInquirySettings();
    getDraft = MockGetInquiryDraft();
    uploadPhoto = MockUploadInquiryPhoto();
    preview = MockPreviewInquiry();
    create = MockCreateInquiry();
    when(() => getSettings(any())).thenAnswer((_) async => const Right(settings));
  });

  InquiryComposerBloc build() => InquiryComposerBloc(
    getInquirySettings: getSettings,
    getInquiryDraft: getDraft,
    uploadInquiryPhoto: uploadPhoto,
    previewInquiry: preview,
    createInquiry: create,
  );

  blocTest<InquiryComposerBloc, InquiryComposerState>(
    'escolher uma categoria pré-seleciona só os contatos que podem receber',
    build: build,
    act: (bloc) => bloc
      ..add(ComposerStarted(contacts: contacts))
      ..add(const ComposerCategoryToggled('c1')),
    verify: (bloc) => expect(bloc.state.recipientIds, ['1', '2']),
  );

  blocTest<InquiryComposerBloc, InquiryComposerState>(
    'desmarcar um contato da categoria e marcar um avulso',
    build: build,
    act: (bloc) => bloc
      ..add(ComposerStarted(contacts: contacts))
      ..add(const ComposerCategoryToggled('c1'))
      ..add(const ComposerContactToggled('1'))
      ..add(const ComposerContactToggled('4')),
    verify: (bloc) {
      expect(bloc.state.recipientIds, ['2', '4']);
      expect(bloc.state.excludedContactIds, {'1'});
      expect(bloc.state.extraContactIds, {'4'});
    },
  );

  blocTest<InquiryComposerBloc, InquiryComposerState>(
    'um avulso que passa a vir pela categoria deixa de ser avulso',
    build: build,
    act: (bloc) => bloc
      ..add(ComposerStarted(contacts: contacts))
      ..add(const ComposerContactToggled('4'))
      ..add(const ComposerCategoryToggled('c2')),
    verify: (bloc) {
      expect(bloc.state.extraContactIds, isEmpty);
      expect(bloc.state.recipientIds, ['2', '4']);
    },
  );

  blocTest<InquiryComposerBloc, InquiryComposerState>(
    'repetir consulta reproduz categorias, desmarcados, avulsos e itens',
    build: () {
      when(() => getDraft(any())).thenAnswer(
        (_) async => const Right(
          InquiryDraft(
            categoryIds: {'c1'},
            contactIds: ['2', '4'],
            items: [InquiryItemDraft(name: 'Dipirona', photoId: 'p1')],
            skippedContacts: [
              SkippedContact(contactName: 'Antiga', reason: 'Contato removido'),
            ],
          ),
        ),
      );
      return build();
    },
    act: (bloc) =>
        bloc.add(ComposerStarted(contacts: contacts, repeatFromId: 'q0')),
    verify: (bloc) {
      final state = bloc.state;
      expect(state.recipientIds, ['2', '4']);
      expect(state.excludedContactIds, {'1'});
      expect(state.extraContactIds, {'4'});
      expect(state.items.single.name, 'Dipirona');
      expect(state.items.single.photo?.id, 'p1');
      expect(state.skippedContacts, hasLength(1));
    },
  );

  blocTest<InquiryComposerBloc, InquiryComposerState>(
    'reordena os itens',
    build: build,
    act: (bloc) => bloc
      ..add(ComposerStarted(contacts: contacts))
      ..add(const ComposerItemAdded())
      ..add(const ComposerItemRenamed(key: 'item-0', name: 'A'))
      ..add(const ComposerItemRenamed(key: 'item-1', name: 'B'))
      ..add(const ComposerItemMoved(oldIndex: 1, newIndex: 0)),
    verify: (bloc) =>
        expect(bloc.state.items.map((item) => item.name), ['B', 'A']),
  );

  blocTest<InquiryComposerBloc, InquiryComposerState>(
    'foto: guarda os bytes locais durante e depois do upload',
    build: () {
      when(() => uploadPhoto(any())).thenAnswer(
        (_) async => const Right(
          InquiryPhoto(
            id: 'p9',
            contentType: 'image/jpeg',
            sizeBytes: 3,
            width: 1,
            height: 1,
          ),
        ),
      );
      return build();
    },
    act: (bloc) => bloc
      ..add(ComposerStarted(contacts: contacts))
      ..add(
        ComposerItemPhotoPicked(
          key: 'item-0',
          bytes: Uint8List.fromList([1, 2, 3]),
          fileName: 'foto.jpg',
        ),
      ),
    verify: (bloc) {
      final photo = bloc.state.items.single.photo!;
      expect(photo.id, 'p9');
      expect(photo.uploading, isFalse);
      expect(photo.localBytes, [1, 2, 3]);
    },
  );

  blocTest<InquiryComposerBloc, InquiryComposerState>(
    'consulta repetida pede confirmação e reenvia com confirmDuplicates',
    build: () {
      var calls = 0;
      when(() => create(any())).thenAnswer((invocation) async {
        calls++;
        final params = invocation.positionalArguments.first as CreateInquiryParams;
        if (calls == 1) {
          expect(params.confirmDuplicates, isFalse);
          return Left(
            DuplicateInquiryFailure('Já receberam.', [
              DuplicateInquiryWarning(
                contactId: '1',
                contactName: 'Contato 1',
                itemName: 'Dipirona',
                sentAt: DateTime.utc(2026, 9, 27),
              ),
            ]),
          );
        }
        expect(params.confirmDuplicates, isTrue);
        expect(params.contactIds, ['1', '2']);
        return Right(created);
      });
      return build();
    },
    act: (bloc) async {
      bloc
        ..add(ComposerStarted(contacts: contacts))
        ..add(const ComposerCategoryToggled('c1'))
        ..add(const ComposerItemRenamed(key: 'item-0', name: 'Dipirona'))
        ..add(const ComposerSubmitted());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.phase, ComposerPhase.duplicates);
      expect(bloc.state.duplicates.single.contactName, 'Contato 1');
      bloc.add(const ComposerSubmitted(confirmDuplicates: true));
    },
    verify: (bloc) {
      expect(bloc.state.phase, ComposerPhase.created);
      expect(bloc.state.created, created);
    },
  );

  test('explica o que falta para enviar', () {
    final base = InquiryComposerState(
      contacts: contacts,
      settings: settings,
      items: const [ComposerItem(key: 'a')],
    );
    expect(base.validationMessage, 'Escolha ao menos um contato.');

    final withContacts = base.copyWith(selectedCategoryIds: {'c1'});
    expect(withContacts.validationMessage, 'Todo item precisa de um nome.');

    final ready = withContacts.copyWith(
      items: const [ComposerItem(key: 'a', name: 'Dipirona')],
    );
    expect(ready.validationMessage, isNull);
  });
}
