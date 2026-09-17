import 'package:dartz/dartz.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/notes/domain/entities/note.dart';
import 'package:olie/features/notes/domain/repositories/note_repository.dart';

class GetNotes implements UseCase<List<Note>, NoParams> {
  final NoteRepository repository;

  GetNotes(this.repository);

  @override
  Future<Either<Failure, List<Note>>> call(NoParams params) {
    return repository.getNotes();
  }
}
