import 'package:dartz/dartz.dart';

import 'package:olie/core/error/exceptions.dart';
import 'package:olie/core/error/failures.dart';
import 'package:olie/features/todo/data/datasources/todo_local_data_source.dart';
import 'package:olie/features/todo/domain/entities/todo.dart';
import 'package:olie/features/todo/domain/repositories/todo_repository.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoLocalDataSource localDataSource;

  TodoRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Todo>>> getTodos() async {
    try {
      final todos = await localDataSource.getTodos();
      return Right(todos);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Todo>> addTodo(String title) async {
    try {
      final todo = await localDataSource.addTodo(title);
      return Right(todo);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Todo>> toggleTodo(String id) async {
    try {
      final todo = await localDataSource.toggleTodo(id);
      return Right(todo);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTodo(String id) async {
    try {
      await localDataSource.deleteTodo(id);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
