import 'package:flutter/material.dart';

class TodoInputField extends StatefulWidget {
  final ValueChanged<String> onSubmitted;

  const TodoInputField({super.key, required this.onSubmitted});

  @override
  State<TodoInputField> createState() => _TodoInputFieldState();
}

class _TodoInputFieldState extends State<TodoInputField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSubmitted(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Adicionar tarefa',
                isDense: true,
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            tooltip: 'Adicionar tarefa',
            onPressed: _submit,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
