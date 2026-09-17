part of 'note_bloc.dart';

enum NoteStatus { initial, loading, success, failure }

class NoteState extends Equatable {
  final NoteStatus status;
  final List<Note> notes;
  final String? errorMessage;

  const NoteState({
    this.status = NoteStatus.initial,
    this.notes = const [],
    this.errorMessage,
  });

  NoteState copyWith({
    NoteStatus? status,
    List<Note>? notes,
    String? errorMessage,
  }) {
    return NoteState(
      status: status ?? this.status,
      notes: notes ?? this.notes,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, notes, errorMessage];
}
