import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:olie/features/notes/presentation/bloc/note_bloc.dart';
import 'package:olie/features/notes/presentation/widgets/note_input_field.dart';
import 'package:olie/features/notes/presentation/widgets/note_list_item.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notas')),
      body: Column(
        children: [
          NoteInputField(
            onSubmitted: (content) =>
                context.read<NoteBloc>().add(NoteAdded(content)),
          ),
          Expanded(
            child: BlocConsumer<NoteBloc, NoteState>(
              listener: (context, state) {
                if (state.status == NoteStatus.failure &&
                    state.errorMessage != null) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(content: Text(state.errorMessage!)),
                    );
                }
              },
              builder: (context, state) {
                if (state.status == NoteStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.notes.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma nota por aqui ainda.'),
                  );
                }

                return ListView.separated(
                  itemCount: state.notes.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final note = state.notes[index];
                    return NoteListItem(
                      key: ValueKey(note.id),
                      note: note,
                      onSave: (content) => context.read<NoteBloc>().add(
                        NoteUpdated(id: note.id, content: content),
                      ),
                      onDelete: () =>
                          context.read<NoteBloc>().add(NoteDeleted(note.id)),
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
