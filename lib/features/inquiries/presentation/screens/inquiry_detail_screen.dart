import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:olie/core/presentation/formatters.dart';
import 'package:olie/core/presentation/olie_widgets.dart';
import 'package:olie/core/theme/app_theme.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry_status.dart';
import 'package:olie/features/inquiries/presentation/bloc/inquiry_bloc.dart';
import 'package:olie/features/inquiries/presentation/screens/inquiry_navigation.dart';
import 'package:olie/features/inquiries/presentation/widgets/countdown_text.dart';
import 'package:olie/features/inquiries/presentation/widgets/inquiry_photo_thumbnail.dart';
import 'package:olie/features/inquiries/presentation/widgets/inquiry_tones.dart';
import 'package:olie/features/whatsapp/presentation/widgets/whatsapp_connection_sheet.dart';

/// Acompanhamento de uma consulta: status de cada contato em tempo real,
/// contagem regressiva até o próximo envio, controles e resumo final.
class InquiryDetailScreen extends StatefulWidget {
  final String inquiryId;

  const InquiryDetailScreen({super.key, required this.inquiryId});

  @override
  State<InquiryDetailScreen> createState() => _InquiryDetailScreenState();
}

class _InquiryDetailScreenState extends State<InquiryDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<InquiryBloc>().add(InquiryDetailRequested(widget.inquiryId));
  }

  Future<void> _cancel(Inquiry inquiry) async {
    final bloc = context.read<InquiryBloc>();
    final p = OliePalette.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar o envio?'),
        content: Text(
          '${inquiry.totals.pending} contato(s) ainda na fila não vão '
          'receber. Quem está recebendo agora termina normalmente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Continuar enviando'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: p.critical),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Cancelar envio'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) bloc.add(InquiryCancelRequested(inquiry.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InquiryBloc, InquiryState>(
      builder: (context, state) {
        final inquiry =
            state.details[widget.inquiryId] ??
            state.inquiries
                .where((candidate) => candidate.id == widget.inquiryId)
                .firstOrNull;

        return Scaffold(
          appBar: AppBar(
            title: Text(inquiry?.simulated ?? false ? 'Simulação' : 'Consulta'),
          ),
          body: inquiry == null
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () async => context.read<InquiryBloc>().add(
                    InquiryDetailRequested(widget.inquiryId),
                  ),
                  child: _buildBody(context, inquiry),
                ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, Inquiry inquiry) {
    final p = OliePalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final totals = inquiry.totals;
    final bloc = context.read<InquiryBloc>();

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Pill(inquiry.status.label, tone: inquiry.status.tone),
                  if (inquiry.simulated) ...[
                    const SizedBox(width: 6),
                    const Pill('Nada foi enviado', tone: Tone.muted),
                  ],
                  const Spacer(),
                  Text(
                    formatDateTime(inquiry.createdAt),
                    style: OlieText.data(context, size: 12),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${totals.sent}/${totals.total}',
                    style: OlieText.figure(context, size: 44),
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      inquiry.simulated ? 'simulados' : 'enviados',
                      style: textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: totals.total == 0 ? 0 : totals.done / totals.total,
                  minHeight: 8,
                  backgroundColor: p.rule,
                  color: p.olive,
                ),
              ),
              const SizedBox(height: 10),
              _statusLine(context, inquiry),
              if (inquiry.isFinished) ...[
                const SizedBox(height: 8),
                FactRow('Enviados', '${totals.sent}'),
                if (totals.failed > 0) FactRow('Com falha', '${totals.failed}'),
                if (totals.cancelled > 0)
                  FactRow('Cancelados', '${totals.cancelled}'),
              ],
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (inquiry.canPause)
                    OutlinedButton.icon(
                      onPressed: () => bloc.add(InquiryPauseRequested(inquiry.id)),
                      icon: const Icon(Icons.pause, size: 18),
                      label: const Text('Pausar'),
                    ),
                  if (inquiry.canResume)
                    FilledButton.icon(
                      onPressed: () =>
                          bloc.add(InquiryResumeRequested(inquiry.id)),
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('Retomar'),
                    ),
                  if (inquiry.canResendFailed)
                    FilledButton.icon(
                      onPressed: () =>
                          bloc.add(InquiryResendFailedRequested(inquiry.id)),
                      icon: const Icon(Icons.replay, size: 18),
                      label: Text('Reenviar ${totals.failed} com falha'),
                    ),
                  if (inquiry.canCancel)
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: p.critical,
                      ),
                      onPressed: () => _cancel(inquiry),
                      icon: const Icon(Icons.stop, size: 18),
                      label: const Text('Cancelar'),
                    ),
                  if (inquiry.isFinished)
                    OutlinedButton.icon(
                      onPressed: () =>
                          openNewInquiry(context, repeatFromId: inquiry.id),
                      icon: const Icon(Icons.content_copy, size: 18),
                      label: const Text('Repetir consulta'),
                    ),
                ],
              ),
            ],
          ),
        ),
        SectionLabel('Itens · ${inquiry.items.length}'),
        for (final item in inquiry.items)
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            leading: item.photoId == null
                ? CircleAvatar(
                    backgroundColor: p.rule,
                    child: Text(
                      '${item.position + 1}',
                      style: OlieText.data(context, color: p.ink),
                    ),
                  )
                : InquiryPhotoThumbnail(photoId: item.photoId, size: 44),
            title: Text('${item.position + 1}. ${item.name}'),
          ),
        SectionLabel('Contatos · ${totals.total}'),
        for (final recipient in inquiry.recipients) ...[
          _RecipientRow(recipient: recipient),
          const Divider(indent: 20),
        ],
        if (inquiry.recipients.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _statusLine(BuildContext context, Inquiry inquiry) {
    final textTheme = Theme.of(context).textTheme;
    final p = OliePalette.of(context);

    switch (inquiry.status) {
      case InquiryStatus.sending:
        final next = inquiry.nextSendAt;
        if (next == null) {
          return Text('Enviando agora…', style: textTheme.bodyMedium);
        }
        return Row(
          children: [
            Text('Próximo contato em ', style: textTheme.bodyMedium),
            CountdownText(
              key: ValueKey(next),
              target: next,
              style: OlieText.data(context, size: 14, color: p.ink),
            ),
          ],
        );
      case InquiryStatus.paused:
        final lostConnection =
            inquiry.pauseReason == InquiryPauseReason.connectionLost;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              inquiry.pauseReason?.label ?? 'Pausada',
              style: textTheme.bodyMedium?.copyWith(
                color: lostConnection ? p.critical : null,
              ),
            ),
            if (lostConnection)
              TextButton.icon(
                onPressed: () => showWhatsAppConnectionSheet(context),
                icon: const Icon(Icons.qr_code_2, size: 18),
                label: const Text('Conectar WhatsApp'),
              ),
          ],
        );
      case InquiryStatus.completed:
        return Text(
          'Concluída em ${formatDateTime(inquiry.finishedAt ?? inquiry.createdAt)}',
          style: textTheme.bodyMedium,
        );
      case InquiryStatus.cancelled:
        return Text('Envio cancelado.', style: textTheme.bodyMedium);
    }
  }
}

class _RecipientRow extends StatelessWidget {
  final InquiryRecipient recipient;

  const _RecipientRow({required this.recipient});

  void _showMessage(BuildContext context) {
    final text = recipient.messageText;
    if (text == null) return;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(recipient.contactName),
        content: SelectableText(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = OliePalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final sentAt = recipient.sentAt;

    return InkWell(
      onTap: recipient.messageText == null ? null : () => _showMessage(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(recipient.contactName, style: textTheme.titleSmall),
                ),
                if (recipient.status == InquiryRecipientStatus.sending) ...[
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                ],
                Pill(recipient.status.label, tone: recipient.status.tone),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              [
                recipient.phone,
                if (sentAt != null) formatDateTime(sentAt),
                if (recipient.attempts > 1) '${recipient.attempts} tentativas',
              ].join(' · '),
              style: OlieText.data(context, size: 12),
            ),
            if (recipient.failureReason != null) ...[
              const SizedBox(height: 4),
              Text(
                recipient.failureReason!,
                style: textTheme.bodySmall?.copyWith(color: p.critical),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
