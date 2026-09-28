import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:olie/core/theme/app_theme.dart';
import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/todo/domain/entities/todo.dart';
import 'package:olie/features/todo/domain/usecases/add_todo.dart';
import 'package:olie/features/todo/domain/usecases/delete_todo.dart';
import 'package:olie/features/todo/domain/usecases/get_todos.dart';
import 'package:olie/features/todo/domain/usecases/toggle_todo.dart';
import 'package:olie/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:olie/features/todo/presentation/widgets/todo_section.dart';

class MockGetTodos extends Mock implements GetTodos {}

class MockAddTodo extends Mock implements AddTodo {}

class MockToggleTodo extends Mock implements ToggleTodo {}

class MockDeleteTodo extends Mock implements DeleteTodo {}

void main() {
  late MockGetTodos getTodos;
  late MockAddTodo addTodo;
  late MockToggleTodo toggleTodo;
  late MockDeleteTodo deleteTodo;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const AddTodoParams(''));
    registerFallbackValue(const ToggleTodoParams(''));
    registerFallbackValue(const DeleteTodoParams(''));
  });

  setUp(() {
    getTodos = MockGetTodos();
    addTodo = MockAddTodo();
    toggleTodo = MockToggleTodo();
    deleteTodo = MockDeleteTodo();
  });

  Future<void> pumpSection(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: BlocProvider(
            create: (_) => TodoBloc(
              getTodos: getTodos,
              addTodo: addTodo,
              toggleTodo: toggleTodo,
              deleteTodo: deleteTodo,
            )..add(const TodosRequested()),
            child: const SingleChildScrollView(child: TodoSection()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('TodoSection shows empty state when there are no todos', (
    tester,
  ) async {
    when(() => getTodos(any())).thenAnswer((_) async => const Right([]));

    await pumpSection(tester);

    expect(find.text('Nenhuma tarefa por aqui ainda.'), findsOneWidget);
  });

  testWidgets('TodoSection renders a todo item returned by the use case', (
    tester,
  ) async {
    const todo = Todo(id: '1', title: 'Comprar leite');
    when(() => getTodos(any())).thenAnswer((_) async => const Right([todo]));

    await pumpSection(tester);

    expect(find.text('Comprar leite'), findsOneWidget);
  });

  testWidgets('TodoSection lists pending todos before done ones', (
    tester,
  ) async {
    when(() => getTodos(any())).thenAnswer(
      (_) async => const Right([
        Todo(id: '1', title: 'Trocar lâmpada', isDone: true),
        Todo(id: '2', title: 'Pagar conta de luz'),
      ]),
    );

    await pumpSection(tester);

    final pendingY = tester.getTopLeft(find.text('Pagar conta de luz')).dy;
    final doneY = tester.getTopLeft(find.text('Trocar lâmpada')).dy;
    expect(pendingY, lessThan(doneY));
    expect(find.text('1 de 2 feitas'), findsOneWidget);
  });
}
