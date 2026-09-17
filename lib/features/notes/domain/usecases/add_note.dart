import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/notes/domain/entities/note.dart';
import 'package:olie/features/notes/domain/repositories/note_repository.dart';

class AddNote implements UseCase<Note, AddNoteParams> {
  final NoteRepository repository;

  AddNote(this.repository);

  @override
  Future<Either<Failure, Note>> call(AddNoteParams params) {
    return repository.addNote(params.content);
  }
}

class AddNoteParams extends Equatable {
  final String content;

  const AddNoteParams(this.content);

  @override
  List<Object?> get props => [content];
}
