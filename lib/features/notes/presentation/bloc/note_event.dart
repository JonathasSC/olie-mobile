part of 'note_bloc.dart';

abstract class NoteEvent extends Equatable {
  const NoteEvent();

  @override
  List<Object?> get props => [];
}

class NotesRequested extends NoteEvent {
  const NotesRequested();
}

class NoteAdded extends NoteEvent {
  final String content;

  const NoteAdded(this.content);

  @override
  List<Object?> get props => [content];
}

class NoteUpdated extends NoteEvent {
  final String id;
  final String content;

  const NoteUpdated({required this.id, required this.content});

  @override
  List<Object?> get props => [id, content];
}

class NoteDeleted extends NoteEvent {
  final String id;

  const NoteDeleted(this.id);

  @override
  List<Object?> get props => [id];
}
