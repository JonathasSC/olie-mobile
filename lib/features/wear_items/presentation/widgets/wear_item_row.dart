import 'package:flutter/material.dart';

import 'package:olie/core/presentation/formatters.dart';
import 'package:olie/core/presentation/olie_widgets.dart';
import 'package:olie/core/theme/app_theme.dart';
import 'package:olie/features/wear_items/domain/entities/wear_item.dart';
import 'package:olie/features/wear_items/domain/entities/wear_status.dart';
import 'package:olie/features/wear_items/presentation/widgets/wear_gauge.dart';

class WearItemRow extends StatelessWidget {
  final WearItem item;
  final VoidCallback onTap;

  const WearItemRow({super.key, required this.item, required this.onTap});

  String _caption() {
    final estimate = item.estimate;
    final date = estimate.estimatedReplacementDate;
    if (estimate.status == WearStatus.inStock || date == null) {
      return 'Guardado desde ${formatShortDate(item.currentCycle.purchaseDate)}';
    }
    final wear = estimate.wearPercentage;
    return 'Troca em ${formatShortDate(date)}'
        '${wear != null ? ' · $wear% usado' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    final estimate = item.estimate;
    final days = estimate.daysRemaining;
    final isStock = estimate.status == WearStatus.inStock;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (!isStock) ...[
                    WearGauge(
                      percentage: estimate.wearPercentage,
                      status: estimate.status,
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(_caption(), style: OlieText.data(context, size: 12)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            if (isStock || days == null)
              const CountdownTag(figure: '—', unit: 'estoque', tone: Tone.muted)
            else
              CountdownTag.days(days, tone: estimate.status.tone),
          ],
        ),
      ),
    );
  }
}
