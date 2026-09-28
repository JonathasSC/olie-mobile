import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:olie/core/presentation/formatters.dart';
import 'package:olie/core/presentation/olie_widgets.dart';
import 'package:olie/core/theme/app_theme.dart';
import 'package:olie/features/contacts/domain/entities/contact.dart';
import 'package:olie/features/contacts/presentation/bloc/contact_bloc.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry_message.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry_support.dart';
import 'package:olie/features/inquiries/presentation/bloc/inquiry_bloc.dart';
import 'package:olie/features/inquiries/presentation/bloc/inquiry_composer_bloc.dart';
import 'package:olie/features/inquiries/presentation/screens/inquiry_navigation.dart';
import 'package:olie/features/inquiries/presentation/widgets/inquiry_photo_thumbnail.dart';
import 'package:olie/features/inquiries/presentation/widgets/message_preview.dart';
import 'package:olie/features/whatsapp/presentation/bloc/whatsapp_bloc.dart';
import 'package:olie/features/whatsapp/presentation/widgets/whatsapp_status_bar.dart';

/// Monta e envia uma consulta: categorias → contatos → itens → prévia.
class NewInquiryScreen extends StatefulWidget {
  const NewInquiryScreen({super.key});

  @override
  State<NewInquiryScreen> createState() => _NewInquiryScreenState();
}

class _NewInquiryScreenState extends State<NewInquiryScreen> {
  /// Um controller por item, pela chave estável do item.
  final Map<String, TextEditingController> _controllers = {};
  final _picker = ImagePicker();

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(ComposerItem item) {
    return _controllers.putIfAbsent(
      item.key,
      () => TextEditingController(text: item.name),
    );
  }

  Future<void> _pickPhoto(ComposerItem item, ImageSource source) async {
    final bloc = context.read<InquiryComposerBloc>();
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 2400,
        maxHeight: 2400,
        imageQuality: 90,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      bloc.add(
        ComposerItemPhotoPicked(key: item.key, bytes: bytes, fileName: file.name),
      );
    } on Exception {
      if (mounted) showToast(context, 'Não foi possível abrir a imagem.');
    }
  }

  Future<void> _choosePhotoSource(ComposerItem item) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tirar foto'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Escolher da galeria ou arquivo'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source != null) await _pickPhoto(item, source);
  }

  Future<void> _onPhaseChanged(
    BuildContext context,
    InquiryComposerState state,
  ) async {
    final bloc = context.read<InquiryComposerBloc>();
    switch (state.phase) {
      case ComposerPhase.failure:
        showToast(context, state.message ?? 'Algo deu errado.');
        bloc.add(const ComposerFeedbackDismissed());
      case ComposerPhase.confirming:
        final confirmed = await _confirmSend(context, state);
        bloc.add(
          confirmed
              ? const ComposerSubmitted()
              : const ComposerFeedbackDismissed(),
        );
      case ComposerPhase.duplicates:
        final confirmed = await _confirmDuplicates(context, state);
        bloc.add(
          confirmed
              ? const ComposerSubmitted(confirmDuplicates: true)
              : const ComposerFeedbackDismissed(),
        );
      case ComposerPhase.created:
        final inquiry = state.created!;
        context.read<InquiryBloc>().add(InquiryCreated(inquiry));
        replaceWithInquiryDetail(context, inquiry.id);
      case ComposerPhase.loading:
      case ComposerPhase.editing:
      case ComposerPhase.loadingPreview:
      case ComposerPhase.submitting:
        break;
    }
  }

  Future<bool> _confirmSend(
    BuildContext context,
    InquiryComposerState state,
  ) async {
    final count = state.recipientIds.length;
    final settings = state.settings;
    final preview = state.preview!;
    final photos = {
      for (final item in state.items)
        if (item.photo?.id != null) item.photo!.id!: item.photo!.localBytes,
    };

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          state.simulate
              ? 'Simular para $count contato(s)?'
              : 'Enviar para $count contato(s)?',
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.simulate
                    ? 'Nada será enviado: você vê o fluxo completo e o texto '
                          'que cada contato receberia.'
                    : settings == null
                    ? 'Cada contato recebe:'
                    : 'Os envios são espaçados de '
                          '${settings.contactIntervalMinSeconds}–'
                          '${settings.contactIntervalMaxSeconds} s entre '
                          'contatos. Cada um recebe:',
                style: Theme.of(dialogContext).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              MessagePreview(
                bubbles: [
                  for (final message in preview.messages)
                    message.type == PreviewMessageType.photo
                        ? PreviewBubble.photo(
                            message.text,
                            photoId: message.photoId,
                            localBytes: photos[message.photoId],
                          )
                        : PreviewBubble.text(message.text),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Voltar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(state.simulate ? 'Simular' : 'Enviar'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<bool> _confirmDuplicates(
    BuildContext context,
    InquiryComposerState state,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Consulta repetida'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(state.message ?? ''),
              const SizedBox(height: 12),
              for (final warning in state.duplicates)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '${warning.contactName} · ${warning.itemName} · '
                    '${formatDateTime(warning.sentAt)}',
                    style: OlieText.data(dialogContext, size: 12),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Revisar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Enviar mesmo assim'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<InquiryComposerBloc, InquiryComposerState>(
          listenWhen: (previous, current) => previous.phase != current.phase,
          listener: _onPhaseChanged,
        ),
        // A agenda pode mudar enquanto o formulário está aberto.
        BlocListener<ContactBloc, ContactState>(
          listenWhen: (previous, current) =>
              previous.contacts != current.contacts,
          listener: (context, state) => context
              .read<InquiryComposerBloc>()
              .add(ComposerContactsUpdated(state.contacts)),
        ),
      ],
      child: BlocBuilder<InquiryComposerBloc, InquiryComposerState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Nova consulta')),
            body: state.phase == ComposerPhase.loading
                ? const Center(child: CircularProgressIndicator())
                : _buildForm(context, state),
            bottomNavigationBar: _SendBar(state: state),
          );
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, InquiryComposerState state) {
    final bloc = context.read<InquiryComposerBloc>();
    final categories = context.watch<ContactBloc>().state.categories;
    final contactable = state.contacts.where((c) => c.contactable).toList();
    final inCategories = contactable
        .where((c) => c.categoryIds.any(state.selectedCategoryIds.contains))
        .toList();
    final others = contactable
        .where((c) => !c.categoryIds.any(state.selectedCategoryIds.contains))
        .toList();
    final maxItems = state.settings?.maxItems;

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (!state.simulate) const WhatsAppStatusBar(),
        if (state.skippedContacts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Text(
              'Fora desta vez: ${state.skippedContacts.map((s) => '${s.contactName} (${s.reason.toLowerCase()})').join(', ')}.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        const SectionLabel('Para quem'),
        if (categories.isEmpty)
          const EmptyHint(
            title: 'Nenhuma categoria de contato.',
            hint: 'Cadastre categorias e contatos na seção Contatos.',
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final category in categories)
                  FilterChip(
                    label: Text(category.name),
                    selected: state.selectedCategoryIds.contains(category.id),
                    onSelected: (_) =>
                        bloc.add(ComposerCategoryToggled(category.id)),
                  ),
              ],
            ),
          ),
        SectionLabel(
          'Contatos · ${state.recipientIds.length} selecionado(s)',
        ),
        if (inCategories.isEmpty && state.extraContactIds.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Escolha uma categoria: os contatos dela entram marcados e você '
              'desmarca quem não quiser consultar.',
            ),
          ),
        for (final contact in inCategories)
          _ContactCheck(
            contact: contact,
            selected: state.isSelected(contact),
            onChanged: () => bloc.add(ComposerContactToggled(contact.id)),
          ),
        if (others.isNotEmpty)
          ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 20),
            title: Text('Outros contatos (${others.length})'),
            initiallyExpanded: state.extraContactIds.isNotEmpty,
            children: [
              for (final contact in others)
                _ContactCheck(
                  contact: contact,
                  selected: state.isSelected(contact),
                  onChanged: () => bloc.add(ComposerContactToggled(contact.id)),
                ),
            ],
          ),
        SectionLabel(
          maxItems == null
              ? 'Itens'
              : 'Itens · ${state.items.length} de $maxItems',
        ),
        ReorderableListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          onReorderItem: (oldIndex, newIndex) => bloc.add(
            ComposerItemMoved(oldIndex: oldIndex, newIndex: newIndex),
          ),
          children: [
            for (var i = 0; i < state.items.length; i++)
              _ItemEditor(
                key: ValueKey(state.items[i].key),
                index: i,
                item: state.items[i],
                controller: _controllerFor(state.items[i]),
                canRemove: state.items.length > 1,
                onChanged: (name) => bloc.add(
                  ComposerItemRenamed(key: state.items[i].key, name: name),
                ),
                onPhoto: () => _choosePhotoSource(state.items[i]),
                onRemovePhoto: () =>
                    bloc.add(ComposerItemPhotoRemoved(state.items[i].key)),
                onRemove: () {
                  _controllers.remove(state.items[i].key)?.dispose();
                  bloc.add(ComposerItemRemoved(state.items[i].key));
                },
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: maxItems != null && state.items.length >= maxItems
                  ? null
                  : () => bloc.add(const ComposerItemAdded()),
              icon: const Icon(Icons.add),
              label: const Text('Adicionar item'),
            ),
          ),
        ),
        const SectionLabel('Pré-visualização'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _LivePreview(state: state),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          title: const Text('Simular'),
          subtitle: const Text(
            'Percorre todo o envio sem mandar nada para ninguém',
          ),
          value: state.simulate,
          onChanged: (value) => bloc.add(ComposerSimulateToggled(value)),
        ),
      ],
    );
  }
}

/// Prévia montada no aparelho a cada tecla (sem esperar a rede); a oficial
/// do backend aparece na confirmação.
class _LivePreview extends StatelessWidget {
  final InquiryComposerState state;

  const _LivePreview({required this.state});

  @override
  Widget build(BuildContext context) {
    final settings = state.settings;
    final names = [
      for (final item in state.items)
        item.name.trim().isEmpty ? '…' : item.name.trim(),
    ];
    if (settings == null || names.isEmpty) {
      return const SizedBox.shrink();
    }

    final message = composeInquiryMessage(
      template: settings.messageTemplate,
      itemNames: names,
      localTime: DateTime.now(),
    );
    return MessagePreview(
      bubbles: [
        PreviewBubble.text(message.text),
        for (var i = 0; i < state.items.length; i++)
          if (state.items[i].photo != null)
            PreviewBubble.photo(
              message.itemCaptions[i],
              photoId: state.items[i].photo!.id,
              localBytes: state.items[i].photo!.localBytes,
            ),
      ],
    );
  }
}

class _ContactCheck extends StatelessWidget {
  final Contact contact;
  final bool selected;
  final VoidCallback onChanged;

  const _ContactCheck({
    required this.contact,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      dense: true,
      value: selected,
      onChanged: (_) => onChanged(),
      title: Text(contact.name),
      subtitle: Text(contact.phone, style: OlieText.data(context, size: 12)),
    );
  }
}

class _ItemEditor extends StatelessWidget {
  final int index;
  final ComposerItem item;
  final TextEditingController controller;
  final bool canRemove;
  final ValueChanged<String> onChanged;
  final VoidCallback onPhoto;
  final VoidCallback onRemovePhoto;
  final VoidCallback onRemove;

  const _ItemEditor({
    super.key,
    required this.index,
    required this.item,
    required this.controller,
    required this.canRemove,
    required this.onChanged,
    required this.onPhoto,
    required this.onRemovePhoto,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final photo = item.photo;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 12, 4),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.drag_indicator),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: 'Item ${index + 1}'),
            ),
          ),
          const SizedBox(width: 8),
          if (photo == null)
            IconButton(
              tooltip: 'Adicionar foto',
              onPressed: onPhoto,
              icon: const Icon(Icons.add_a_photo_outlined),
            )
          else
            Stack(
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onTap: onPhoto,
                  onLongPress: onRemovePhoto,
                  child: InquiryPhotoThumbnail(
                    photoId: photo.id,
                    localBytes: photo.localBytes,
                    size: 44,
                  ),
                ),
                if (photo.uploading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          if (photo != null && !photo.uploading)
            IconButton(
              tooltip: 'Remover foto',
              onPressed: onRemovePhoto,
              icon: const Icon(Icons.hide_image_outlined, size: 20),
            ),
          IconButton(
            tooltip: 'Remover item',
            onPressed: canRemove ? onRemove : null,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

/// Botão de envio fixo no rodapé, com o motivo quando não dá para enviar.
class _SendBar extends StatelessWidget {
  final InquiryComposerState state;

  const _SendBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final p = OliePalette.of(context);
    final connected = context.select(
      (WhatsAppBloc bloc) => bloc.state.connection.isConnected,
    );
    final busy =
        state.phase == ComposerPhase.loadingPreview ||
        state.phase == ComposerPhase.submitting;
    final count = state.recipientIds.length;
    final blocker = !state.simulate && !connected
        ? 'Conecte o WhatsApp ou ative a simulação.'
        : state.validationMessage;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (blocker != null && state.phase != ComposerPhase.loading) ...[
              Text(
                blocker,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: p.muted,
                ),
              ),
              const SizedBox(height: 6),
            ],
            FilledButton.icon(
              onPressed: blocker != null || busy
                  ? null
                  : () => context.read<InquiryComposerBloc>().add(
                      const ComposerPreviewRequested(),
                    ),
              icon: busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(state.simulate ? Icons.science_outlined : Icons.send),
              label: Text(
                state.simulate
                    ? 'Simular para $count contato(s)'
                    : 'Enviar para $count contato(s)',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
