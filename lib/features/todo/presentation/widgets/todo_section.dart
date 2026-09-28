import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:olie/core/presentation/olie_widgets.dart';
import 'package:olie/core/theme/app_theme.dart';
import 'package:olie/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:olie/features/todo/presentation/widgets/todo_input_field.dart';
import 'package:olie/features/todo/presentation/widgets/todo_list_item.dart';

/// Tarefas do dia: campo de captura e lista, pendentes antes das feitas.
class TodoSection extends StatelessWidget {
  const TodoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TodoBloc, TodoState>(
      builder: (context, state) {
        final pending = state.todos.where((todo) => !todo.isDone).toList();
        final done = state.todos.where((todo) => todo.isDone).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionLabel(
              'Tarefas',
              trailing: state.todos.isEmpty
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        '${done.length} de ${state.todos.length} feitas',
                        style: OlieText.data(context, size: 12),
                      ),
                    ),
            ),
            TodoInputField(
              onSubmitted: (title) =>
                  context.read<TodoBloc>().add(TodoAdded(title)),
            ),
            if (state.status == TodoStatus.loading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (state.todos.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Text(
                  'Nenhuma tarefa por aqui ainda.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            else
              for (final todo in [...pending, ...done])
                TodoListItem(
                  key: ValueKey(todo.id),
                  todo: todo,
                  onToggle: () =>
                      context.read<TodoBloc>().add(TodoToggled(todo.id)),
                  onDelete: () =>
                      context.read<TodoBloc>().add(TodoDeleted(todo.id)),
                ),
          ],
        );
      },
    );
  }
}
