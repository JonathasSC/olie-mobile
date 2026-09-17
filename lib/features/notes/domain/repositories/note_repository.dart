import 'package:dartz/dartz.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/features/notes/domain/entities/note.dart';

abstract class NoteRepository {
  Future<Either<Failure, List<Note>>> getNotes();

  Future<Either<Failure, Note>> addNote(String content);

  Future<Either<Failure, Note>> updateNote({
    required String id,
    required String content,
  });

  Future<Either<Failure, void>> deleteNote(String id);
}
