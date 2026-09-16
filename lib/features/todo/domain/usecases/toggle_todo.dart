import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/todo/domain/entities/todo.dart';
import 'package:olie/features/todo/domain/repositories/todo_repository.dart';

class ToggleTodo implements UseCase<Todo, ToggleTodoParams> {
  final TodoRepository repository;

  ToggleTodo(this.repository);

  @override
  Future<Either<Failure, Todo>> call(ToggleTodoParams params) {
    return repository.toggleTodo(params.id);
  }
}

class ToggleTodoParams extends Equatable {
  final String id;

  const ToggleTodoParams(this.id);

  @override
  List<Object?> get props => [id];
}
