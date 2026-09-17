import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/notes/domain/entities/note.dart';
import 'package:olie/features/notes/domain/repositories/note_repository.dart';

class UpdateNote implements UseCase<Note, UpdateNoteParams> {
  final NoteRepository repository;

  UpdateNote(this.repository);

  @override
  Future<Either<Failure, Note>> call(UpdateNoteParams params) {
    return repository.updateNote(id: params.id, content: params.content);
  }
}

class UpdateNoteParams extends Equatable {
  final String id;
  final String content;

  const UpdateNoteParams({required this.id, required this.content});

  @override
  List<Object?> get props => [id, content];
}
