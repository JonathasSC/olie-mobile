import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:olie/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:olie/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:olie/features/todo/presentation/widgets/todo_input_field.dart';
import 'package:olie/features/todo/presentation/widgets/todo_list_item.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarefas'),
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              return IconButton(
                tooltip: 'Notificações',
                icon: Badge(
                  isLabelVisible: state.notifications.isNotEmpty,
                  label: Text('${state.notifications.length}'),
                  child: const Icon(Icons.notifications_outlined),
                ),
                onPressed: () =>
                    Navigator.of(context).pushNamed('/notifications'),
              );
            },
          ),
          IconButton(
            tooltip: 'Metas de economia',
            icon: const Icon(Icons.savings_outlined),
            onPressed: () => Navigator.of(context).pushNamed('/savings-goals'),
          ),
          IconButton(
            tooltip: 'Itens planejados',
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => Navigator.of(context).pushNamed('/planned-items'),
          ),
          IconButton(
            tooltip: 'Notas',
            icon: const Icon(Icons.note_outlined),
            onPressed: () => Navigator.of(context).pushNamed('/notes'),
          ),
        ],
      ),
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
