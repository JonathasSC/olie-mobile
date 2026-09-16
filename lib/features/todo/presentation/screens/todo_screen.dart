import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:olie/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:olie/features/todo/presentation/widgets/todo_input_field.dart';
import 'package:olie/features/todo/presentation/widgets/todo_list_item.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tarefas')),
      body: Column(
        children: [
          TodoInputField(
            onSubmitted: (title) =>
                context.read<TodoBloc>().add(TodoAdded(title)),
          ),
          Expanded(
            child: BlocConsumer<TodoBloc, TodoState>(
              listener: (context, state) {
                if (state.status == TodoStatus.failure &&
                    state.errorMessage != null) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(content: Text(state.errorMessage!)),
                    );
                }
              },
              builder: (context, state) {
                if (state.status == TodoStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.todos.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma tarefa por aqui ainda.'),
                  );
                }

                return ListView.builder(
                  itemCount: state.todos.length,
                  itemBuilder: (context, index) {
                    final todo = state.todos[index];
                    return TodoListItem(
                      todo: todo,
                      onToggle: () =>
                          context.read<TodoBloc>().add(TodoToggled(todo.id)),
                      onDelete: () =>
                          context.read<TodoBloc>().add(TodoDeleted(todo.id)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
