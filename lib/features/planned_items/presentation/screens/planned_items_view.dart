import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:olie/core/presentation/formatters.dart';
import 'package:olie/core/presentation/olie_widgets.dart';
import 'package:olie/core/theme/app_theme.dart';
import 'package:olie/features/planned_items/domain/entities/planned_item.dart';
import 'package:olie/features/planned_items/presentation/bloc/planned_item_bloc.dart';
import 'package:olie/features/planned_items/presentation/widgets/planned_item_row.dart';
import 'package:olie/features/planned_items/presentation/widgets/planned_item_sheets.dart';

/// Lista de compras planejadas, agrupada pelo prazo.
class PlannedItemsView extends StatelessWidget {
  const PlannedItemsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlannedItemBloc, PlannedItemState>(
      builder: (context, state) {
        if (state.status == PlannedItemStatus.loading && state.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.items.isEmpty) {
          return const EmptyHint(
            title: 'Nenhuma compra planejada.',
            hint:
                'Anote o que a casa vai precisar, com valor e data, e o '
                'Olie avisa quando o prazo chegar.',
          );
        }

        final items = [...state.items]
          ..sort((a, b) => a.estimatedDate.compareTo(b.estimatedDate));
        final overdue = <PlannedItem>[];
        final soon = <PlannedItem>[];
        final later = <PlannedItem>[];
        for (final item in items) {
          final days = daysUntil(item.estimatedDate);
          (days < 0 ? overdue : (days <= 30 ? soon : later)).add(item);
        }

        double sum(List<PlannedItem> list) =>
            list.fold(0, (total, item) => total + item.estimatedValue);

        return ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            _Summary(
              next30: sum(overdue) + sum(soon),
              total: sum(items),
              count: items.length,
            ),
            for (final (label, group) in [
              ('Atrasadas', overdue),
              ('Próximos 30 dias', soon),
              ('Mais adiante', later),
            ])
              if (group.isNotEmpty) ...[
                SectionLabel(
                  label,
                  trailing: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      formatCurrency(sum(group)),
                      style: OlieText.data(context, size: 12),
                    ),
                  ),
                ),
                for (final item in group) ...[
                  PlannedItemRow(
                    key: ValueKey(item.id),
                    item: item,
                    onTap: () => showPlannedItemSheet(context, item),
                  ),
                  const Divider(indent: 20),
                ],
              ],
          ],
        );
      },
    );
  }
}

class _Summary extends StatelessWidget {
  final double next30;
  final double total;
  final int count;

  const _Summary({
    required this.next30,
    required this.total,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final p = OliePalette.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A PAGAR ATÉ ${formatShortDate(DateTime.now().add(const Duration(days: 30))).toUpperCase()}',
            style: OlieText.label(context),
          ),
          const SizedBox(height: 4),
          Text(
            formatCurrency(next30),
            style: OlieText.figure(context, size: 44, color: p.money),
          ),
          const SizedBox(height: 6),
          Text(
            '$count ${count == 1 ? 'compra planejada' : 'compras planejadas'} · '
            '${formatCurrency(total)} no total',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
