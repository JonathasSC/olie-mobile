import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/todo/domain/entities/todo.dart';
import 'package:olie/features/todo/domain/usecases/add_todo.dart';
import 'package:olie/features/todo/domain/usecases/delete_todo.dart';
import 'package:olie/features/todo/domain/usecases/get_todos.dart';
import 'package:olie/features/todo/domain/usecases/toggle_todo.dart';

part 'todo_event.dart';
part 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final GetTodos getTodos;
  final AddTodo addTodo;
  final ToggleTodo toggleTodo;
  final DeleteTodo deleteTodo;

  TodoBloc({
    required this.getTodos,
    required this.addTodo,
    required this.toggleTodo,
    required this.deleteTodo,
  }) : super(const TodoState()) {
    on<TodosRequested>(_onTodosRequested);
    on<TodoAdded>(_onTodoAdded);
    on<TodoToggled>(_onTodoToggled);
    on<TodoDeleted>(_onTodoDeleted);
  }

  Future<void> _onTodosRequested(
    TodosRequested event,
    Emitter<TodoState> emit,
  ) async {
    emit(state.copyWith(status: TodoStatus.loading));

    final result = await getTodos(const NoParams());

    result.fold(
      (failure) => emit(state.copyWith(
        status: TodoStatus.failure,
        errorMessage: failure.message,
      )),
      (todos) => emit(state.copyWith(
        status: TodoStatus.success,
        todos: todos,
      )),
    );
  }

  Future<void> _onTodoAdded(
    TodoAdded event,
    Emitter<TodoState> emit,
  ) async {
    final result = await addTodo(AddTodoParams(event.title));

    result.fold(
      (failure) => emit(state.copyWith(
        status: TodoStatus.failure,
        errorMessage: failure.message,
      )),
      (todo) => emit(state.copyWith(
        status: TodoStatus.success,
        todos: [...state.todos, todo],
      )),
    );
  }

  Future<void> _onTodoToggled(
    TodoToggled event,
    Emitter<TodoState> emit,
  ) async {
    final result = await toggleTodo(ToggleTodoParams(event.id));

    result.fold(
      (failure) => emit(state.copyWith(
        status: TodoStatus.failure,
        errorMessage: failure.message,
      )),
      (updated) => emit(state.copyWith(
        status: TodoStatus.success,
        todos: [
          for (final todo in state.todos)
            if (todo.id == updated.id) updated else todo,
        ],
      )),
    );
  }

  Future<void> _onTodoDeleted(
    TodoDeleted event,
    Emitter<TodoState> emit,
  ) async {
    final result = await deleteTodo(DeleteTodoParams(event.id));

    result.fold(
      (failure) => emit(state.copyWith(
        status: TodoStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: TodoStatus.success,
        todos: state.todos.where((todo) => todo.id != event.id).toList(),
      )),
    );
  }
}
