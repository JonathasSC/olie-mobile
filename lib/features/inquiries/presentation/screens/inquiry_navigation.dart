import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:olie/core/di/injection_container.dart' as di;
import 'package:olie/features/contacts/presentation/bloc/contact_bloc.dart';
import 'package:olie/features/inquiries/presentation/bloc/inquiry_bloc.dart';
import 'package:olie/features/inquiries/presentation/bloc/inquiry_composer_bloc.dart';
import 'package:olie/features/inquiries/presentation/screens/inquiry_detail_screen.dart';
import 'package:olie/features/inquiries/presentation/screens/new_inquiry_screen.dart';
import 'package:olie/features/whatsapp/presentation/bloc/whatsapp_bloc.dart';

/// As telas de consulta são rotas próprias (fora da aba), então levam
/// consigo os blocs da sessão que a aba já tem.
Widget _withSessionBlocs(BuildContext context, Widget child) {
  return MultiBlocProvider(
    providers: [
      BlocProvider.value(value: context.read<InquiryBloc>()),
      BlocProvider.value(value: context.read<ContactBloc>()),
      BlocProvider.value(value: context.read<WhatsAppBloc>()),
    ],
    child: child,
  );
}

Future<void> openInquiryDetail(BuildContext context, String inquiryId) {
  final screen = _withSessionBlocs(
    context,
    InquiryDetailScreen(inquiryId: inquiryId),
  );
  return Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
}

/// Formulário de nova consulta; com [repeatFromId], já preenchido com os
/// dados de uma consulta anterior.
Future<void> openNewInquiry(BuildContext context, {String? repeatFromId}) {
  final contacts = context.read<ContactBloc>().state.contacts;
  final screen = _withSessionBlocs(
    context,
    BlocProvider(
      create: (_) => di.sl<InquiryComposerBloc>()
        ..add(ComposerStarted(contacts: contacts, repeatFromId: repeatFromId)),
      child: const NewInquiryScreen(),
    ),
  );
  return Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
}

/// Troca a tela atual (o formulário) pelo detalhe da consulta criada.
void replaceWithInquiryDetail(BuildContext context, String inquiryId) {
  final screen = _withSessionBlocs(
    context,
    InquiryDetailScreen(inquiryId: inquiryId),
  );
  Navigator.of(
    context,
  ).pushReplacement(MaterialPageRoute(builder: (_) => screen));
}
