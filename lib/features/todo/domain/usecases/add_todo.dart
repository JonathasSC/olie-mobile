import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/todo/domain/entities/todo.dart';
import 'package:olie/features/todo/domain/repositories/todo_repository.dart';

class AddTodo implements UseCase<Todo, AddTodoParams> {
  final TodoRepository repository;

  AddTodo(this.repository);

  @override
  Future<Either<Failure, Todo>> call(AddTodoParams params) {
    return repository.addTodo(params.title);
  }
}

class AddTodoParams extends Equatable {
  final String title;

  const AddTodoParams(this.title);

  @override
  List<Object?> get props => [title];
}
