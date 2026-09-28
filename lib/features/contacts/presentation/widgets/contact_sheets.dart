import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:olie/core/presentation/olie_widgets.dart';
import 'package:olie/core/theme/app_theme.dart';
import 'package:olie/features/contacts/domain/entities/contact.dart';
import 'package:olie/features/contacts/domain/entities/contact_category.dart';
import 'package:olie/features/contacts/presentation/bloc/contact_bloc.dart';
import 'package:olie/features/contacts/presentation/widgets/contact_form.dart';

/// Painel de cadastro de contato.
Future<void> showNewContactSheet(BuildContext context) {
  final bloc = context.read<ContactBloc>();
  return showOlieSheet(
    context,
    eyebrow: 'Contatos',
    title: 'Novo contato',
    builder: (sheetContext) => ContactForm(
      categories: bloc.state.categories,
      submitLabel: 'Adicionar',
      onCancel: () => Navigator.of(sheetContext).pop(),
      onSubmit:
          ({
            required name,
            required phone,
            required categoryIds,
            required active,
            required doNotContact,
          }) {
            Navigator.of(sheetContext).pop();
            bloc.add(
              ContactAdded(
                name: name,
                phone: phone,
                categoryIds: categoryIds,
                active: active,
                doNotContact: doNotContact,
              ),
            );
          },
    ),
  );
}

/// Painel de edição de um contato, com a opção de excluir.
Future<void> showContactSheet(BuildContext context, Contact contact) {
  final bloc = context.read<ContactBloc>();
  return showOlieSheet(
    context,
    eyebrow: 'Contatos',
    title: contact.name,
    builder: (sheetContext) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ContactForm(
          initial: contact,
          categories: bloc.state.categories,
          submitLabel: 'Salvar',
          onCancel: () => Navigator.of(sheetContext).pop(),
          onSubmit:
              ({
                required name,
                required phone,
                required categoryIds,
                required active,
                required doNotContact,
              }) {
                Navigator.of(sheetContext).pop();
                bloc.add(
                  ContactUpdated(
                    id: contact.id,
                    name: name,
                    phone: phone,
                    categoryIds: categoryIds,
                    active: active,
                    doNotContact: doNotContact,
                  ),
                );
              },
        ),
        const Divider(height: 32),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: OliePalette.of(sheetContext).critical,
          ),
          onPressed: () async {
            if (!await confirmDelete(sheetContext, contact.name)) return;
            bloc.add(ContactDeleted(contact.id));
            if (sheetContext.mounted) Navigator.of(sheetContext).pop();
          },
          icon: const Icon(Icons.delete_outline, size: 18),
          label: const Text('Excluir contato'),
        ),
      ],
    ),
  );
}

/// Lista de categorias de contato: criar, renomear e remover.
Future<void> showContactCategoriesSheet(BuildContext context) {
  final bloc = context.read<ContactBloc>();
  return showOlieSheet(
    context,
    eyebrow: 'Contatos',
    title: 'Categorias',
    builder: (_) => BlocProvider.value(
      value: bloc,
      child: const _CategoriesPanel(),
    ),
  );
}

class _CategoriesPanel extends StatefulWidget {
  const _CategoriesPanel();

  @override
  State<_CategoriesPanel> createState() => _CategoriesPanelState();
}

class _CategoriesPanelState extends State<_CategoriesPanel> {
  final _newController = TextEditingController();

  @override
  void dispose() {
    _newController.dispose();
    super.dispose();
  }

  void _add() {
    final name = _newController.text.trim();
    if (name.isEmpty) return;
    context.read<ContactBloc>().add(ContactCategoryAdded(name));
    _newController.clear();
  }

  Future<void> _rename(ContactCategory category) async {
    final controller = TextEditingController(text: category.name);
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Renomear categoria'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nome'),
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!mounted || name == null || name.trim().isEmpty) return;
    context.read<ContactBloc>().add(
      ContactCategoryRenamed(id: category.id, name: name),
    );
  }

  Future<void> _delete(ContactCategory category) async {
    final bloc = context.read<ContactBloc>();
    if (category.contactsCount == 0) {
      if (!await confirmDelete(context, category.name)) return;
      bloc.add(ContactCategoryDeleted(id: category.id));
      return;
    }

    // Categoria em uso: a remoção desvincula os contatos (eles continuam
    // existindo, só perdem essa categoria).
    final p = OliePalette.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Remover "${category.name}"?'),
        content: Text(
          '${category.contactsCount} contato(s) estão nesta categoria e vão '
          'perder o vínculo. Os contatos em si não são excluídos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Manter'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: p.critical),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Desvincular e remover'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      bloc.add(ContactCategoryDeleted(id: category.id, unlinkContacts: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactBloc, ContactState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.categories.isEmpty)
              const EmptyHint(
                title: 'Nenhuma categoria.',
                hint: 'Agrupe os contatos por tipo, como "Farmácias" ou '
                    '"Fornecedores", para consultar vários de uma vez.',
              ),
            for (final category in state.categories)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(category.name),
                subtitle: Text(
                  category.contactsCount == 1
                      ? '1 contato'
                      : '${category.contactsCount} contatos',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Renomear',
                      onPressed: () => _rename(category),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      tooltip: 'Remover',
                      onPressed: () => _delete(category),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Nova categoria',
                    ),
                    onSubmitted: (_) => _add(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: 'Adicionar',
                  onPressed: _add,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Escolhe um arquivo `.yaml`/`.yml`/`.json` e mostra o resultado da
/// importação (ou a linha de cada problema, quando recusada).
Future<void> pickAndImportContacts(BuildContext context) async {
  final bloc = context.read<ContactBloc>();
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['yaml', 'yml', 'json'],
    withData: true,
  );
  final file = result?.files.single;
  final bytes = file?.bytes;
  if (file == null || bytes == null || !context.mounted) return;

  bloc.add(ContactsImportRequested(bytes: bytes, fileName: file.name));
  await showOlieSheet(
    context,
    eyebrow: 'Contatos',
    title: 'Importar arquivo',
    builder: (_) => BlocProvider.value(
      value: bloc,
      child: _ImportResult(fileName: file.name),
    ),
  );
  bloc.add(const ContactsImportDismissed());
}

class _ImportResult extends StatelessWidget {
  final String fileName;

  const _ImportResult({required this.fileName});

  @override
  Widget build(BuildContext context) {
    final p = OliePalette.of(context);
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<ContactBloc, ContactState>(
      builder: (context, state) {
        final children = <Widget>[
          FactRow('Arquivo', fileName),
          const SizedBox(height: 12),
        ];

        switch (state.importStatus) {
          case ContactImportStatus.idle:
          case ContactImportStatus.importing:
            children.add(const Center(child: CircularProgressIndicator()));
          case ContactImportStatus.success:
            final result = state.importResult!;
            children.addAll([
              FactRow('Categorias criadas', '${result.categoriesCreated}'),
              FactRow('Contatos criados', '${result.contactsCreated}'),
              FactRow('Contatos atualizados', '${result.contactsUpdated}'),
            ]);
          case ContactImportStatus.failure:
            children.add(
              Text(
                state.importMessage ?? 'Não foi possível importar.',
                style: textTheme.bodyMedium?.copyWith(color: p.critical),
              ),
            );
            for (final error in state.importErrors) {
              children.add(
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 72,
                        child: Text(
                          'linha ${error.line}',
                          style: OlieText.data(context, size: 12),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          error.field == null
                              ? error.message
                              : '${error.field}: ${error.message}',
                          style: textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
        }

        children.addAll([
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ]);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        );
      },
    );
  }
}
