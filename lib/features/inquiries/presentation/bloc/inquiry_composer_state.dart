part of 'inquiry_composer_bloc.dart';

enum ComposerPhase {
  loading,
  editing,
  loadingPreview,

  /// Prévia pronta: aguardando o usuário confirmar o envio.
  confirming,
  submitting,

  /// Contatos já receberam estes itens: pedir confirmação.
  duplicates,
  created,
  failure,
}

class ComposerPhoto extends Equatable {
  /// Id no backend; `null` enquanto o upload não terminou.
  final String? id;

  /// Bytes escolhidos agora (miniatura sem ida à rede).
  final Uint8List? localBytes;
  final bool uploading;

  const ComposerPhoto({this.id, this.localBytes, this.uploading = false});

  @override
  List<Object?> get props => [id, localBytes, uploading];
}

class ComposerItem extends Equatable {
  /// Identidade estável na tela (o nome muda e a ordem também).
  final String key;
  final String name;
  final ComposerPhoto? photo;

  const ComposerItem({required this.key, this.name = '', this.photo});

  ComposerItem copyWith({String? name, ComposerPhoto? photo}) {
    return ComposerItem(
      key: key,
      name: name ?? this.name,
      photo: photo ?? this.photo,
    );
  }

  ComposerItem withoutPhoto() => ComposerItem(key: key, name: name);

  @override
  List<Object?> get props => [key, name, photo];
}

class InquiryComposerState extends Equatable {
  final InquirySettings? settings;
  final List<Contact> contacts;
  final Set<String> selectedCategoryIds;

  /// Contatos das categorias escolhidas que o usuário desmarcou.
  final Set<String> excludedContactIds;

  /// Contatos fora das categorias escolhidas, marcados um a um.
  final Set<String> extraContactIds;
  final List<ComposerItem> items;
  final bool simulate;
  final ComposerPhase phase;
  final String? message;
  final InquiryPreview? preview;
  final List<DuplicateInquiryWarning> duplicates;
  final List<SkippedContact> skippedContacts;
  final Inquiry? created;

  const InquiryComposerState({
    this.settings,
    this.contacts = const [],
    this.selectedCategoryIds = const {},
    this.excludedContactIds = const {},
    this.extraContactIds = const {},
    this.items = const [],
    this.simulate = false,
    this.phase = ComposerPhase.loading,
    this.message,
    this.preview,
    this.duplicates = const [],
    this.skippedContacts = const [],
    this.created,
  });

  bool isSelected(Contact contact) {
    if (!contact.contactable) return false;
    if (extraContactIds.contains(contact.id)) return true;
    return contact.categoryIds.any(selectedCategoryIds.contains) &&
        !excludedContactIds.contains(contact.id);
  }

  /// Destinatários na ordem de envio (a ordem da agenda).
  List<String> get recipientIds => [
    for (final contact in contacts)
      if (isSelected(contact)) contact.id,
  ];

  List<InquiryItemDraft> get itemDrafts => [
    for (final item in items)
      InquiryItemDraft(name: item.name.trim(), photoId: item.photo?.id),
  ];

  bool get uploadingPhoto => items.any((item) => item.photo?.uploading ?? false);

  /// O que impede o envio agora, ou `null` se está tudo certo.
  String? get validationMessage {
    if (recipientIds.isEmpty) return 'Escolha ao menos um contato.';
    if (items.isEmpty) return 'Adicione ao menos um item.';
    if (items.any((item) => item.name.trim().isEmpty)) {
      return 'Todo item precisa de um nome.';
    }
    if (uploadingPhoto) return 'Aguarde o envio das fotos.';
    final max = settings?.maxRecipients;
    if (max != null && recipientIds.length > max) {
      return 'Uma consulta pode ter no máximo $max contatos.';
    }
    return null;
  }

  InquiryComposerState copyWith({
    InquirySettings? settings,
    List<Contact>? contacts,
    Set<String>? selectedCategoryIds,
    Set<String>? excludedContactIds,
    Set<String>? extraContactIds,
    List<ComposerItem>? items,
    bool? simulate,
    ComposerPhase? phase,
    String? message,
    InquiryPreview? preview,
    List<DuplicateInquiryWarning>? duplicates,
    List<SkippedContact>? skippedContacts,
    Inquiry? created,
  }) {
    return InquiryComposerState(
      settings: settings ?? this.settings,
      contacts: contacts ?? this.contacts,
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
      excludedContactIds: excludedContactIds ?? this.excludedContactIds,
      extraContactIds: extraContactIds ?? this.extraContactIds,
      items: items ?? this.items,
      simulate: simulate ?? this.simulate,
      phase: phase ?? this.phase,
      message: message,
      preview: preview ?? this.preview,
      duplicates: duplicates ?? this.duplicates,
      skippedContacts: skippedContacts ?? this.skippedContacts,
      created: created ?? this.created,
    );
  }

  @override
  List<Object?> get props => [
    settings,
    contacts,
    selectedCategoryIds,
    excludedContactIds,
    extraContactIds,
    items,
    simulate,
    phase,
    message,
    preview,
    duplicates,
    skippedContacts,
    created,
  ];
}
