import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:olie/core/presentation/olie_widgets.dart';
import 'package:olie/core/theme/app_theme.dart';
import 'package:olie/features/contacts/domain/entities/contact.dart';
import 'package:olie/features/contacts/domain/entities/contact_file.dart';
import 'package:olie/features/contacts/presentation/bloc/contact_bloc.dart';
import 'package:olie/features/contacts/presentation/widgets/contact_sheets.dart';

enum _Menu { categories, import, exportYaml, exportJson }

/// Agenda usada nas consultas: filtro por categoria, categorias, importação
/// e exportação do arquivo YAML/JSON.
class ContactsView extends StatefulWidget {
  const ContactsView({super.key});

  @override
  State<ContactsView> createState() => _ContactsViewState();
}

class _ContactsViewState extends State<ContactsView> {
  String? _categoryFilter;

  void _onMenu(_Menu option) {
    final bloc = context.read<ContactBloc>();
    switch (option) {
      case _Menu.categories:
        showContactCategoriesSheet(context);
      case _Menu.import:
        pickAndImportContacts(context);
      case _Menu.exportYaml:
        bloc.add(const ContactsExportRequested(ContactFileFormat.yaml));
      case _Menu.exportJson:
        bloc.add(const ContactsExportRequested(ContactFileFormat.json));
    }
  }

  Future<void> _save(ContactFile file) async {
    final bloc = context.read<ContactBloc>();
    try {
      final path = await FilePicker.saveFile(
        dialogTitle: 'Salvar contatos',
        fileName: file.fileName,
        bytes: file.bytes,
      );
      if (mounted && path != null) showToast(context, 'Contatos exportados.');
    } on Exception {
      if (mounted) showToast(context, 'Não foi possível salvar o arquivo.');
    } finally {
      bloc.add(const ContactsExportHandled());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContactBloc, ContactState>(
      listenWhen: (previous, current) =>
          current.exportFile != null && previous.exportFile == null,
      listener: (context, state) => _save(state.exportFile!),
      builder: (context, state) {
        if (state.status == ContactStatus.loading && state.contacts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final filter = _categoryFilter;
        final contacts = filter == null
            ? state.contacts
            : state.contacts
                  .where((contact) => contact.categoryIds.contains(filter))
                  .toList();

        return ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final category in state.categories) ...[
                            FilterChip(
                              label: Text(
                                '${category.name}  ${category.contactsCount}',
                              ),
                              selected: filter == category.id,
                              onSelected: (selected) => setState(
                                () => _categoryFilter = selected
                                    ? category.id
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ],
                      ),
                    ),
                  ),
                  PopupMenuButton<_Menu>(
                    tooltip: 'Mais opções',
                    onSelected: _onMenu,
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: _Menu.categories,
                        child: Text('Categorias'),
                      ),
                      PopupMenuItem(
                        value: _Menu.import,
                        child: Text('Importar arquivo (YAML/JSON)'),
                      ),
                      PopupMenuItem(
                        value: _Menu.exportYaml,
                        child: Text('Exportar como YAML'),
                      ),
                      PopupMenuItem(
                        value: _Menu.exportJson,
                        child: Text('Exportar como JSON'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (state.contacts.isEmpty)
              EmptyHint(
                title: 'Nenhum contato ainda.',
                hint: state.categories.isEmpty
                    ? 'Comece criando categorias (menu ⋮ › Categorias) e '
                          'depois cadastre os contatos, ou importe um arquivo.'
                    : 'Cadastre quem você costuma consultar ou importe um '
                          'arquivo YAML/JSON.',
              )
            else if (contacts.isEmpty)
              const EmptyHint(title: 'Nenhum contato nessa categoria.'),
            for (final contact in contacts) ...[
              _ContactRow(
                key: ValueKey(contact.id),
                contact: contact,
                categoryNames: [
                  for (final id in contact.categoryIds)
                    ?state.categoryById(id)?.name,
                ],
                onTap: () => showContactSheet(context, contact),
              ),
              const Divider(indent: 20),
            ],
          ],
        );
      },
    );
  }
}

class _ContactRow extends StatelessWidget {
  final Contact contact;
  final List<String> categoryNames;
  final VoidCallback onTap;

  const _ContactRow({
    super.key,
    required this.contact,
    required this.categoryNames,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = OliePalette.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    contact.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: contact.contactable ? null : p.muted,
                    ),
                  ),
                ),
                if (contact.doNotContact)
                  const Pill('Não contatar', tone: Tone.critical)
                else if (!contact.active)
                  const Pill('Inativo', tone: Tone.muted),
              ],
            ),
            const SizedBox(height: 4),
            Text(contact.phone, style: OlieText.data(context, size: 12)),
            if (categoryNames.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (final name in categoryNames)
                    Pill(name, tone: Tone.calm),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
