import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:olie/core/presentation/formatters.dart';
import 'package:olie/core/presentation/olie_widgets.dart';
import 'package:olie/core/theme/app_theme.dart';
import 'package:olie/features/notes/domain/entities/note.dart';
import 'package:olie/features/notes/presentation/bloc/note_bloc.dart';
import 'package:olie/features/notes/presentation/widgets/note_input_field.dart';

/// Notas soltas: captura no topo, mais recentes primeiro.
class NotesView extends StatelessWidget {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NoteInputField(
          onSubmitted: (content) =>
              context.read<NoteBloc>().add(NoteAdded(content)),
        ),
        Expanded(
          child: BlocBuilder<NoteBloc, NoteState>(
            builder: (context, state) {
              if (state.status == NoteStatus.loading && state.notes.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.notes.isEmpty) {
                return const EmptyHint(
                  title: 'Nenhuma nota.',
                  hint:
                      'Medidas da janela, modelo do filtro, senha do '
                      'Wi-Fi da visita: escreva acima e guarde.',
                );
              }

              final notes = [...state.notes]
                ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

              return ListView.separated(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: notes.length,
                separatorBuilder: (_, _) => const Divider(indent: 20),
                itemBuilder: (context, index) => _NoteRow(
                  key: ValueKey(notes[index].id),
                  note: notes[index],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _NoteRow extends StatelessWidget {
  final Note note;

  const _NoteRow({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showNoteSheet(context, note),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.content,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 6),
            Text(
              formatDateTime(note.updatedAt),
              style: OlieText.data(context, size: 11.5),
            ),
          ],
        ),
      ),
    );
  }
}

/// Painel de edição de uma nota.
Future<void> showNoteSheet(BuildContext context, Note note) {
  final bloc = context.read<NoteBloc>();
  return showOlieSheet(
    context,
    eyebrow: 'Nota · ${formatDateTime(note.updatedAt)}',
    title: 'Editar nota',
    builder: (sheetContext) => _NoteEditor(note: note, bloc: bloc),
  );
}

class _NoteEditor extends StatefulWidget {
  final Note note;
  final NoteBloc bloc;

  const _NoteEditor({required this.note, required this.bloc});

  @override
  State<_NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<_NoteEditor> {
  late final _controller = TextEditingController(text: widget.note.content);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final content = _controller.text.trim();
    if (content.isNotEmpty && content != widget.note.content) {
      widget.bloc.add(NoteUpdated(id: widget.note.id, content: content));
    }
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final preview = widget.note.content.length > 30
        ? '${widget.note.content.substring(0, 30)}…'
        : widget.note.content;
    if (!await confirmDelete(context, preview)) return;
    widget.bloc.add(NoteDeleted(widget.note.id));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final p = OliePalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          autofocus: true,
          minLines: 4,
          maxLines: 12,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: p.critical),
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Excluir'),
            ),
            const Spacer(),
            FilledButton(onPressed: _save, child: const Text('Salvar')),
          ],
        ),
      ],
    );
  }
}
