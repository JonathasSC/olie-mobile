import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import 'package:olie/core/error/failures.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/todo/domain/repositories/todo_repository.dart';

class DeleteTodo implements UseCase<void, DeleteTodoParams> {
  final TodoRepository repository;

  DeleteTodo(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteTodoParams params) {
    return repository.deleteTodo(params.id);
  }
}

class DeleteTodoParams extends Equatable {
  final String id;

  const DeleteTodoParams(this.id);

  @override
  List<Object?> get props => [id];
}
