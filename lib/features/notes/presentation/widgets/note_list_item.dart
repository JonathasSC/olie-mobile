import 'package:flutter/material.dart';

import 'package:olie/features/notes/domain/entities/note.dart';

class NoteListItem extends StatefulWidget {
  final Note note;
  final ValueChanged<String> onSave;
  final VoidCallback onDelete;

  const NoteListItem({
    super.key,
    required this.note,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<NoteListItem> createState() => _NoteListItemState();
}

class _NoteListItemState extends State<NoteListItem> {
  late final TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.note.content);
  }

  @override
  void didUpdateWidget(covariant NoteListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEditing && oldWidget.note.content != widget.note.content) {
      _controller.text = widget.note.content;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _controller.text = widget.note.content;
      _isEditing = true;
    });
  }

  void _cancelEditing() {
    setState(() {
      _controller.text = widget.note.content;
      _isEditing = false;
    });
  }

  void _save() {
    final newContent = _controller.text.trim();
    setState(() => _isEditing = false);
    if (newContent.isNotEmpty && newContent != widget.note.content) {
      widget.onSave(newContent);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 6,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ),
            IconButton(
              tooltip: 'Cancelar',
              onPressed: _cancelEditing,
              icon: const Icon(Icons.close),
            ),
            IconButton.filled(
              tooltip: 'Salvar',
              onPressed: _save,
              icon: const Icon(Icons.check),
            ),
          ],
        ),
      );
    }

    return Dismissible(
      key: ValueKey(widget.note.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => widget.onDelete(),
      background: Container(
        color: Theme.of(context).colorScheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
      child: ListTile(
        onTap: _startEditing,
        title: Text(
          widget.note.content,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(_formatDate(widget.note.updatedAt)),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(local.day)}/${twoDigits(local.month)}/${local.year} '
        '${twoDigits(local.hour)}:${twoDigits(local.minute)}';
  }
}
