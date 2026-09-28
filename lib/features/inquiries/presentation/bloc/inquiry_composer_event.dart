part of 'inquiry_composer_bloc.dart';

abstract class InquiryComposerEvent extends Equatable {
  const InquiryComposerEvent();

  @override
  List<Object?> get props => [];
}

class ComposerStarted extends InquiryComposerEvent {
  final List<Contact> contacts;

  /// Consulta anterior a repetir (formulário já preenchido).
  final String? repeatFromId;

  const ComposerStarted({required this.contacts, this.repeatFromId});

  @override
  List<Object?> get props => [contacts, repeatFromId];
}

class ComposerContactsUpdated extends InquiryComposerEvent {
  final List<Contact> contacts;

  const ComposerContactsUpdated(this.contacts);

  @override
  List<Object?> get props => [contacts];
}

class ComposerCategoryToggled extends InquiryComposerEvent {
  final String categoryId;

  const ComposerCategoryToggled(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class ComposerContactToggled extends InquiryComposerEvent {
  final String contactId;

  const ComposerContactToggled(this.contactId);

  @override
  List<Object?> get props => [contactId];
}

class ComposerItemAdded extends InquiryComposerEvent {
  const ComposerItemAdded();
}

class ComposerItemRemoved extends InquiryComposerEvent {
  final String key;

  const ComposerItemRemoved(this.key);

  @override
  List<Object?> get props => [key];
}

class ComposerItemRenamed extends InquiryComposerEvent {
  final String key;
  final String name;

  const ComposerItemRenamed({required this.key, required this.name});

  @override
  List<Object?> get props => [key, name];
}

class ComposerItemMoved extends InquiryComposerEvent {
  final int oldIndex;

  /// Posição final do item (já descontada a remoção da posição antiga).
  final int newIndex;

  const ComposerItemMoved({required this.oldIndex, required this.newIndex});

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

class ComposerItemPhotoPicked extends InquiryComposerEvent {
  final String key;
  final Uint8List bytes;
  final String fileName;

  const ComposerItemPhotoPicked({
    required this.key,
    required this.bytes,
    required this.fileName,
  });

  @override
  List<Object?> get props => [key, bytes, fileName];
}

class ComposerItemPhotoRemoved extends InquiryComposerEvent {
  final String key;

  const ComposerItemPhotoRemoved(this.key);

  @override
  List<Object?> get props => [key];
}

class ComposerSimulateToggled extends InquiryComposerEvent {
  final bool simulate;

  const ComposerSimulateToggled(this.simulate);

  @override
  List<Object?> get props => [simulate];
}

/// Busca a prévia oficial e abre a confirmação do envio.
class ComposerPreviewRequested extends InquiryComposerEvent {
  const ComposerPreviewRequested();
}

class ComposerSubmitted extends InquiryComposerEvent {
  /// O usuário já viu o alerta de consulta repetida e quer enviar mesmo assim.
  final bool confirmDuplicates;

  const ComposerSubmitted({this.confirmDuplicates = false});

  @override
  List<Object?> get props => [confirmDuplicates];
}

/// Fecha aviso, confirmação ou alerta e volta à edição.
class ComposerFeedbackDismissed extends InquiryComposerEvent {
  const ComposerFeedbackDismissed();
}
