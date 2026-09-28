import 'package:flutter/material.dart';

import 'package:olie/core/theme/app_theme.dart';
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
    final p = OliePalette.of(context);
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 4, 0),
        child: Row(
          children: [
            Checkbox(value: todo.isDone, onChanged: (_) => onToggle()),
            Expanded(
              child: Text(
                todo.title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: todo.isDone ? p.muted : p.ink,
                  decoration: todo.isDone ? TextDecoration.lineThrough : null,
                  decorationColor: p.muted,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Remover tarefa',
              icon: Icon(Icons.close, size: 18, color: p.muted),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
