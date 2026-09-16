import 'package:flutter/material.dart';

import 'package:olie/features/todo/domain/entities/todo.dart';

class TodoListItem extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TodoListItem({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        color: Theme.of(context).colorScheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
      child: CheckboxListTile(
        value: todo.isDone,
        onChanged: (_) => onToggle(),
        title: Text(
          todo.title,
          style: todo.isDone
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null,
        ),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}
