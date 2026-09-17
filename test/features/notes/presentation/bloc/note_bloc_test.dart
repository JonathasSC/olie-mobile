import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/notes/domain/entities/note.dart';
import 'package:olie/features/notes/domain/usecases/add_note.dart';
import 'package:olie/features/notes/domain/usecases/delete_note.dart';
import 'package:olie/features/notes/domain/usecases/get_notes.dart';
import 'package:olie/features/notes/domain/usecases/update_note.dart';
import 'package:olie/features/notes/presentation/bloc/note_bloc.dart';

class MockGetNotes extends Mock implements GetNotes {}

class MockAddNote extends Mock implements AddNote {}

class MockUpdateNote extends Mock implements UpdateNote {}

class MockDeleteNote extends Mock implements DeleteNote {}

void main() {
  late MockGetNotes getNotes;
  late MockAddNote addNote;
  late MockUpdateNote updateNote;
  late MockDeleteNote deleteNote;

  final note = Note(
    id: 'uuid',
    content: 'Lembrar de renegociar a assinatura da academia.',
    createdAt: DateTime.utc(2026, 9, 16, 14, 30),
    updatedAt: DateTime.utc(2026, 9, 16, 14, 30),
  );

  setUpAll(() {
    registerFallbackValue(const AddNoteParams('fallback'));
    registerFallbackValue(
      const UpdateNoteParams(id: 'fallback', content: 'fallback'),
    );
    registerFallbackValue(const DeleteNoteParams('fallback'));
  });

  setUp(() {
    getNotes = MockGetNotes();
    addNote = MockAddNote();
    updateNote = MockUpdateNote();
    deleteNote = MockDeleteNote();
  });

  NoteBloc buildBloc() => NoteBloc(
        getNotes: getNotes,
        addNote: addNote,
        updateNote: updateNote,
        deleteNote: deleteNote,
      );

  blocTest<NoteBloc, NoteState>(
    'emite [loading, success] quando as notas são carregadas',
    build: () {
      when(() => getNotes(const NoParams()))
          .thenAnswer((_) async => Right([note]));
      return buildBloc();
    },
    act: (bloc) => bloc.add(const NotesRequested()),
    expect: () => [
      const NoteState(status: NoteStatus.loading),
      NoteState(status: NoteStatus.success, notes: [note]),
    ],
  );

  blocTest<NoteBloc, NoteState>(
    'emite [failure] quando o carregamento das notas falha',
    build: () {
      when(() => getNotes(const NoParams())).thenAnswer(
        (_) async => const Left(ServerFailure('Erro ao comunicar com o servidor.')),
      );
      return buildBloc();
    },
    act: (bloc) => bloc.add(const NotesRequested()),
    expect: () => [
      const NoteState(status: NoteStatus.loading),
      const NoteState(
        status: NoteStatus.failure,
        errorMessage: 'Erro ao comunicar com o servidor.',
      ),
    ],
  );

  blocTest<NoteBloc, NoteState>(
    'adiciona a nota criada ao início da lista',
    build: () {
      when(() => addNote(any())).thenAnswer((_) async => Right(note));
      return buildBloc();
    },
    act: (bloc) => bloc.add(NoteAdded(note.content)),
    expect: () => [
      NoteState(status: NoteStatus.success, notes: [note]),
    ],
  );

  blocTest<NoteBloc, NoteState>(
    'remove a nota excluída da lista',
    seed: () => NoteState(notes: [note]),
    build: () {
      when(() => deleteNote(any())).thenAnswer((_) async => const Right(null));
      return buildBloc();
    },
    act: (bloc) => bloc.add(NoteDeleted(note.id)),
    expect: () => [
      const NoteState(status: NoteStatus.success, notes: []),
    ],
  );
}
