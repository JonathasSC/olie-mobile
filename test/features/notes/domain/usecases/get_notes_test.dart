import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/notes/domain/entities/note.dart';
import 'package:olie/features/notes/domain/repositories/note_repository.dart';
import 'package:olie/features/notes/domain/usecases/get_notes.dart';

class MockNoteRepository extends Mock implements NoteRepository {}

void main() {
  late MockNoteRepository repository;
  late GetNotes usecase;

  setUp(() {
    repository = MockNoteRepository();
    usecase = GetNotes(repository);
  });

  final notes = [
    Note(
      id: 'uuid',
      content: 'Lembrar de renegociar a assinatura da academia.',
      createdAt: DateTime.utc(2026, 9, 16, 14, 30),
      updatedAt: DateTime.utc(2026, 9, 16, 14, 30),
    ),
  ];

  test('deve retornar a lista de notas quando o repositório é bem-sucedido', () async {
    when(() => repository.getNotes()).thenAnswer((_) async => Right(notes));

    final result = await usecase(const NoParams());

    expect(result, Right(notes));
    verify(() => repository.getNotes()).called(1);
    verifyNoMoreInteractions(repository);
  });
}
