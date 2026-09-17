import 'package:dartz/dartz.dart';

import 'package:olie/core/error/exceptions.dart';
import 'package:olie/core/error/failures.dart';
import 'package:olie/features/notes/data/datasources/note_remote_data_source.dart';
import 'package:olie/features/notes/domain/entities/note.dart';
import 'package:olie/features/notes/domain/repositories/note_repository.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteRemoteDataSource remoteDataSource;

  NoteRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Note>>> getNotes() {
    return _request(() => remoteDataSource.getNotes());
  }

  @override
  Future<Either<Failure, Note>> addNote(String content) {
    return _request(() => remoteDataSource.addNote(content));
  }

  @override
  Future<Either<Failure, Note>> updateNote({
    required String id,
    required String content,
  }) {
    return _request(
      () => remoteDataSource.updateNote(id: id, content: content),
    );
  }

  @override
  Future<Either<Failure, void>> deleteNote(String id) {
    return _request(() => remoteDataSource.deleteNote(id));
  }

  Future<Either<Failure, T>> _request<T>(Future<T> Function() request) async {
    try {
      final result = await request();
      return Right(result);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
