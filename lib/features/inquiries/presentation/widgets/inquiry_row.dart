import 'package:flutter/material.dart';

import 'package:olie/core/presentation/formatters.dart';
import 'package:olie/core/presentation/olie_widgets.dart';
import 'package:olie/core/theme/app_theme.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry.dart';
import 'package:olie/features/inquiries/domain/entities/inquiry_status.dart';
import 'package:olie/features/inquiries/presentation/widgets/inquiry_tones.dart';

/// Linha do histórico: itens, quando, status e progresso.
class InquiryRow extends StatelessWidget {
  final Inquiry inquiry;
  final VoidCallback onTap;

  const InquiryRow({super.key, required this.inquiry, required this.onTap});

  String _progress() {
    final totals = inquiry.totals;
    final parts = ['${totals.sent}/${totals.total} enviados'];
    if (totals.failed > 0) parts.add('${totals.failed} com falha');
    if (totals.cancelled > 0) parts.add('${totals.cancelled} cancelados');
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final p = OliePalette.of(context);
    final totals = inquiry.totals;
    final names = inquiry.items.map((item) => item.name).join(', ');

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    names,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                if (inquiry.simulated) ...[
                  const Pill('Simulação', tone: Tone.muted),
                  const SizedBox(width: 6),
                ],
                Pill(inquiry.status.label, tone: inquiry.status.tone),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: totals.total == 0 ? 0 : totals.done / totals.total,
                minHeight: 4,
                backgroundColor: p.rule,
                color: inquiry.status == InquiryStatus.sending
                    ? p.olive
                    : inquiry.status.tone.color(p),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${formatDateTime(inquiry.createdAt)} · ${_progress()}',
              style: OlieText.data(context, size: 12),
            ),
          ],
        ),
      ),
    );
  }
}
