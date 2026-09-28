import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/contacts/domain/entities/contact.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry_support.dart';
import 'package:olie/features/inquiries/domain/usecases/create_inquiry.dart';
import 'package:olie/features/inquiries/domain/usecases/get_inquiry_draft.dart';
import 'package:olie/features/inquiries/domain/usecases/get_inquiry_settings.dart';
import 'package:olie/features/inquiries/domain/usecases/inquiry_id_params.dart';
import 'package:olie/features/inquiries/domain/usecases/preview_inquiry.dart';
import 'package:olie/features/inquiries/domain/usecases/upload_inquiry_photo.dart';

part 'inquiry_composer_event.dart';
part 'inquiry_composer_state.dart';

/// Formulário de nova consulta: destinatários (por categoria, com ajustes),
/// itens com foto, simulação e o envio com o alerta de repetição.
class InquiryComposerBloc
    extends Bloc<InquiryComposerEvent, InquiryComposerState> {
  final GetInquirySettings getInquirySettings;
  final GetInquiryDraft getInquiryDraft;
  final UploadInquiryPhoto uploadInquiryPhoto;
  final PreviewInquiry previewInquiry;
  final CreateInquiry createInquiry;

  int _nextKey = 0;

  InquiryComposerBloc({
    required this.getInquirySettings,
    required this.getInquiryDraft,
    required this.uploadInquiryPhoto,
    required this.previewInquiry,
    required this.createInquiry,
  }) : super(const InquiryComposerState()) {
    on<ComposerStarted>(_onStarted);
    on<ComposerContactsUpdated>(
      (event, emit) => emit(state.copyWith(contacts: event.contacts)),
    );
    on<ComposerCategoryToggled>(_onCategoryToggled);
    on<ComposerContactToggled>(_onContactToggled);
    on<ComposerItemAdded>(
      (event, emit) => emit(state.copyWith(
        items: [...state.items, ComposerItem(key: _newKey())],
      )),
    );
    on<ComposerItemRemoved>(
      (event, emit) => emit(state.copyWith(
        items: state.items.where((item) => item.key != event.key).toList(),
      )),
    );
    on<ComposerItemRenamed>(
      (event, emit) => emit(state.copyWith(
        items: _updateItem(event.key, (item) => item.copyWith(name: event.name)),
      )),
    );
    on<ComposerItemMoved>(_onItemMoved);
    on<ComposerItemPhotoPicked>(_onItemPhotoPicked);
    on<ComposerItemPhotoRemoved>(
      (event, emit) => emit(state.copyWith(
        items: _updateItem(event.key, (item) => item.withoutPhoto()),
      )),
    );
    on<ComposerSimulateToggled>(
      (event, emit) => emit(state.copyWith(simulate: event.simulate)),
    );
    on<ComposerPreviewRequested>(_onPreviewRequested);
    on<ComposerSubmitted>(_onSubmitted);
    on<ComposerFeedbackDismissed>(
      (event, emit) => emit(state.copyWith(phase: ComposerPhase.editing)),
    );
  }

  String _newKey() => 'item-${_nextKey++}';

  Future<void> _onStarted(
    ComposerStarted event,
    Emitter<InquiryComposerState> emit,
  ) async {
    emit(state.copyWith(
      contacts: event.contacts,
      items: [ComposerItem(key: _newKey())],
      phase: ComposerPhase.loading,
    ));

    final settings = await getInquirySettings(const NoParams());
    settings.fold(
      (failure) => emit(state.copyWith(
        phase: ComposerPhase.failure,
        message: failure.message,
      )),
      (settings) => emit(state.copyWith(
        settings: settings,
        phase: ComposerPhase.editing,
      )),
    );

    final repeatFromId = event.repeatFromId;
    if (repeatFromId == null) return;

    final draft = await getInquiryDraft(InquiryIdParams(repeatFromId));
    draft.fold(
      (failure) => emit(state.copyWith(
        phase: ComposerPhase.failure,
        message: failure.message,
      )),
      (draft) => emit(_fromDraft(draft)),
    );
  }

  /// Reproduz a seleção da consulta anterior: mesmas categorias, com os
  /// contatos desmarcados e os avulsos daquela vez.
  InquiryComposerState _fromDraft(InquiryDraft draft) {
    final byCategory = _contactableIn(draft.categoryIds);
    final chosen = draft.contactIds.toSet();
    return state.copyWith(
      selectedCategoryIds: draft.categoryIds,
      excludedContactIds: byCategory.difference(chosen),
      extraContactIds: chosen.difference(byCategory),
      items: [
        for (final item in draft.items)
          ComposerItem(
            key: _newKey(),
            name: item.name,
            photo: item.photoId == null ? null : ComposerPhoto(id: item.photoId!),
          ),
      ],
      skippedContacts: draft.skippedContacts,
      phase: ComposerPhase.editing,
    );
  }

  void _onCategoryToggled(
    ComposerCategoryToggled event,
    Emitter<InquiryComposerState> emit,
  ) {
    final categories = {...state.selectedCategoryIds};
    if (!categories.remove(event.categoryId)) categories.add(event.categoryId);

    // Contatos que entram pela categoria deixam de ser "avulsos".
    final byCategory = _contactableIn(categories);
    emit(state.copyWith(
      selectedCategoryIds: categories,
      extraContactIds: state.extraContactIds.difference(byCategory),
    ));
  }

  void _onContactToggled(
    ComposerContactToggled event,
    Emitter<InquiryComposerState> emit,
  ) {
    final id = event.contactId;
    final inCategory = _contactableIn(state.selectedCategoryIds).contains(id);
    if (inCategory) {
      final excluded = {...state.excludedContactIds};
      if (!excluded.remove(id)) excluded.add(id);
      emit(state.copyWith(excludedContactIds: excluded));
    } else {
      final extra = {...state.extraContactIds};
      if (!extra.remove(id)) extra.add(id);
      emit(state.copyWith(extraContactIds: extra));
    }
  }

  void _onItemMoved(
    ComposerItemMoved event,
    Emitter<InquiryComposerState> emit,
  ) {
    final items = [...state.items];
    items.insert(event.newIndex, items.removeAt(event.oldIndex));
    emit(state.copyWith(items: items));
  }

  Future<void> _onItemPhotoPicked(
    ComposerItemPhotoPicked event,
    Emitter<InquiryComposerState> emit,
  ) async {
    emit(state.copyWith(
      items: _updateItem(
        event.key,
        (item) => item.copyWith(
          photo: ComposerPhoto(localBytes: event.bytes, uploading: true),
        ),
      ),
    ));

    final result = await uploadInquiryPhoto(
      UploadInquiryPhotoParams(
        bytes: event.bytes,
        fileName: event.fileName,
        maxBytes: state.settings?.maxPhotoUploadBytes,
      ),
    );
    result.fold(
      (failure) => emit(state.copyWith(
        items: _updateItem(event.key, (item) => item.withoutPhoto()),
        phase: ComposerPhase.failure,
        message: failure.message,
      )),
      (photo) => emit(state.copyWith(
        items: _updateItem(
          event.key,
          (item) => item.copyWith(
            photo: ComposerPhoto(id: photo.id, localBytes: event.bytes),
          ),
        ),
      )),
    );
  }

  Future<void> _onPreviewRequested(
    ComposerPreviewRequested event,
    Emitter<InquiryComposerState> emit,
  ) async {
    final validation = state.validationMessage;
    if (validation != null) {
      emit(state.copyWith(phase: ComposerPhase.failure, message: validation));
      return;
    }

    emit(state.copyWith(phase: ComposerPhase.loadingPreview));
    final result = await previewInquiry(PreviewInquiryParams(state.itemDrafts));
    result.fold(
      (failure) => emit(state.copyWith(
        phase: ComposerPhase.failure,
        message: failure.message,
      )),
      (preview) => emit(state.copyWith(
        phase: ComposerPhase.confirming,
        preview: preview,
      )),
    );
  }

  Future<void> _onSubmitted(
    ComposerSubmitted event,
    Emitter<InquiryComposerState> emit,
  ) async {
    emit(state.copyWith(phase: ComposerPhase.submitting));

    final settings = state.settings;
    final result = await createInquiry(
      CreateInquiryParams(
        categoryIds: state.selectedCategoryIds,
        contactIds: state.recipientIds,
        items: state.itemDrafts,
        simulate: state.simulate,
        confirmDuplicates: event.confirmDuplicates,
        maxItems: settings?.maxItems,
        maxRecipients: settings?.maxRecipients,
      ),
    );
    result.fold(
      (failure) => emit(
        failure is DuplicateInquiryFailure
            ? state.copyWith(
                phase: ComposerPhase.duplicates,
                message: failure.message,
                duplicates: failure.warnings,
              )
            : state.copyWith(
                phase: ComposerPhase.failure,
                message: failure.message,
              ),
      ),
      (inquiry) => emit(state.copyWith(
        phase: ComposerPhase.created,
        created: inquiry,
      )),
    );
  }

  Set<String> _contactableIn(Set<String> categoryIds) => {
    for (final contact in state.contacts)
      if (contact.contactable &&
          contact.categoryIds.any(categoryIds.contains))
        contact.id,
  };

  List<ComposerItem> _updateItem(
    String key,
    ComposerItem Function(ComposerItem item) update,
  ) => [
    for (final item in state.items) item.key == key ? update(item) : item,
  ];
}
