import 'package:flutter/material.dart';

import 'package:olie/core/presentation/formatters.dart';
import 'package:olie/core/presentation/olie_widgets.dart';
import 'package:olie/core/theme/app_theme.dart';
import 'package:olie/features/planned_items/domain/entities/planned_item.dart';
import 'package:olie/features/planned_items/domain/entities/planned_item_priority.dart';

extension PlannedItemPriorityTone on PlannedItemPriority {
  Tone get tone => switch (this) {
    PlannedItemPriority.essential => Tone.calm,
    PlannedItemPriority.desirable => Tone.money,
    PlannedItemPriority.superfluous => Tone.muted,
  };
}

class PlannedItemRow extends StatelessWidget {
  final PlannedItem item;
  final VoidCallback onTap;

  const PlannedItemRow({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = OliePalette.of(context);
    final days = daysUntil(item.estimatedDate);

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
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 10,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Pill(item.priority.label, tone: item.priority.tone),
                      Text(
                        formatCurrency(item.estimatedValue),
                        style: OlieText.data(
                          context,
                          color: p.money,
                          weight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        formatShortDate(item.estimatedDate),
                        style: OlieText.data(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            CountdownTag.days(days, tone: toneForDays(days, calm: Tone.money)),
          ],
        ),
      ),
    );
  }
}
