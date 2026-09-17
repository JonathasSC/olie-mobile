import 'package:flutter/material.dart';

class NoteInputField extends StatefulWidget {
  final ValueChanged<String> onSubmitted;

  const NoteInputField({super.key, required this.onSubmitted});

  @override
  State<NoteInputField> createState() => _NoteInputFieldState();
}

class _NoteInputFieldState extends State<NoteInputField> {
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
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Nova nota',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.newline,
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: _submit,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
