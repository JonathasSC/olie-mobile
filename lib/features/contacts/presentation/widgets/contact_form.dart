import 'package:flutter/material.dart';

import 'package:olie/features/contacts/domain/entities/contact.dart';
import 'package:olie/features/contacts/domain/entities/contact_category.dart';
import 'package:olie/features/contacts/domain/entities/phone_number.dart';

typedef ContactFormSubmit =
    void Function({
      required String name,
      required String phone,
      required Set<String> categoryIds,
      required bool active,
      required bool doNotContact,
    });

class ContactForm extends StatefulWidget {
  final Contact? initial;
  final List<ContactCategory> categories;
  final String submitLabel;
  final ContactFormSubmit onSubmit;
  final VoidCallback onCancel;

  const ContactForm({
    super.key,
    this.initial,
    required this.categories,
    required this.submitLabel,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late Set<String> _categoryIds;
  late bool _active;
  late bool _doNotContact;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameController = TextEditingController(text: initial?.name);
    _phoneController = TextEditingController(text: initial?.phone ?? '+55 ');
    _categoryIds = {...?initial?.categoryIds};
    _active = initial?.active ?? true;
    _doNotContact = initial?.doNotContact ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = 'Informe o nome do contato.');
      return;
    }
    if (normalizePhone(_phoneController.text) == null) {
      setState(
        () => _errorText =
            'Telefone inválido: use o código do país, ex.: +55 11 99999-9999.',
      );
      return;
    }
    if (_categoryIds.isEmpty) {
      setState(() => _errorText = 'Escolha ao menos uma categoria.');
      return;
    }

    widget.onSubmit(
      name: name,
      phone: _phoneController.text,
      categoryIds: _categoryIds,
      active: _active,
      doNotContact: _doNotContact,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Nome',
            hintText: 'Farmácia Central, Ferragens do Zé...',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'WhatsApp',
            helperText: 'Com código do país, ex.: +55 11 99999-9999',
          ),
        ),
        const SizedBox(height: 16),
        Text('Categorias', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        if (widget.categories.isEmpty)
          Text(
            'Crie uma categoria em “Categorias” antes de cadastrar contatos.',
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in widget.categories)
                FilterChip(
                  label: Text(category.name),
                  selected: _categoryIds.contains(category.id),
                  onSelected: (selected) => setState(() {
                    if (selected) {
                      _categoryIds.add(category.id);
                    } else {
                      _categoryIds.remove(category.id);
                    }
                  }),
                ),
            ],
          ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Ativo'),
          subtitle: const Text('Contatos inativos não recebem consultas'),
          value: _active,
          onChanged: (value) => setState(() => _active = value),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Pediu para não ser contatado'),
          subtitle: const Text('Fica fora de qualquer envio'),
          value: _doNotContact,
          onChanged: (value) => setState(() => _doNotContact = value),
        ),
        if (_errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            _errorText!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: widget.onCancel,
              child: const Text('Cancelar'),
            ),
            const SizedBox(width: 8),
            FilledButton(onPressed: _submit, child: Text(widget.submitLabel)),
          ],
        ),
      ],
    );
  }
}
