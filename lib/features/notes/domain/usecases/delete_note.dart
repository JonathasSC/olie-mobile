import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/notes/domain/repositories/note_repository.dart';

class DeleteNote implements UseCase<void, DeleteNoteParams> {
  final NoteRepository repository;

  DeleteNote(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteNoteParams params) {
    return repository.deleteNote(params.id);
  }
}

class DeleteNoteParams extends Equatable {
  final String id;

  const DeleteNoteParams(this.id);

  @override
  List<Object?> get props => [id];
}
