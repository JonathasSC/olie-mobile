import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/notes/domain/entities/note.dart';
import 'package:olie/features/notes/domain/usecases/add_note.dart';
import 'package:olie/features/notes/domain/usecases/delete_note.dart';
import 'package:olie/features/notes/domain/usecases/get_notes.dart';
import 'package:olie/features/notes/domain/usecases/update_note.dart';

part 'note_event.dart';
part 'note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final GetNotes getNotes;
  final AddNote addNote;
  final UpdateNote updateNote;
  final DeleteNote deleteNote;

  NoteBloc({
    required this.getNotes,
    required this.addNote,
    required this.updateNote,
    required this.deleteNote,
  }) : super(const NoteState()) {
    on<NotesRequested>(_onNotesRequested);
    on<NoteAdded>(_onNoteAdded);
    on<NoteUpdated>(_onNoteUpdated);
    on<NoteDeleted>(_onNoteDeleted);
  }

  Future<void> _onNotesRequested(
    NotesRequested event,
    Emitter<NoteState> emit,
  ) async {
    emit(state.copyWith(status: NoteStatus.loading));

    final result = await getNotes(const NoParams());

    result.fold(
      (failure) => emit(state.copyWith(
        status: NoteStatus.failure,
        errorMessage: failure.message,
      )),
      (notes) => emit(state.copyWith(
        status: NoteStatus.success,
        notes: notes,
      )),
    );
  }

  Future<void> _onNoteAdded(
    NoteAdded event,
    Emitter<NoteState> emit,
  ) async {
    final result = await addNote(AddNoteParams(event.content));

    result.fold(
      (failure) => emit(state.copyWith(
        status: NoteStatus.failure,
        errorMessage: failure.message,
      )),
      (note) => emit(state.copyWith(
        status: NoteStatus.success,
        notes: [note, ...state.notes],
      )),
    );
  }

  Future<void> _onNoteUpdated(
    NoteUpdated event,
    Emitter<NoteState> emit,
  ) async {
    final result = await updateNote(
      UpdateNoteParams(id: event.id, content: event.content),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: NoteStatus.failure,
        errorMessage: failure.message,
      )),
      (updated) => emit(state.copyWith(
        status: NoteStatus.success,
        notes: [
          for (final note in state.notes)
            if (note.id == updated.id) updated else note,
        ],
      )),
    );
  }

  Future<void> _onNoteDeleted(
    NoteDeleted event,
    Emitter<NoteState> emit,
  ) async {
    final result = await deleteNote(DeleteNoteParams(event.id));

    result.fold(
      (failure) => emit(state.copyWith(
        status: NoteStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: NoteStatus.success,
        notes: state.notes.where((note) => note.id != event.id).toList(),
      )),
    );
  }
}
