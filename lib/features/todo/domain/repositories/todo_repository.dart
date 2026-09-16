import 'package:dartz/dartz.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/features/todo/domain/entities/todo.dart';

abstract class TodoRepository {
  Future<Either<Failure, List<Todo>>> getTodos();

  Future<Either<Failure, Todo>> addTodo(String title);

  Future<Either<Failure, Todo>> toggleTodo(String id);

  Future<Either<Failure, void>> deleteTodo(String id);
}
