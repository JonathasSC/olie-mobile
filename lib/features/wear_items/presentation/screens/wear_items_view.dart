import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:olie/core/presentation/olie_widgets.dart';
import 'package:olie/core/theme/app_theme.dart';
import 'package:olie/features/wear_items/domain/entities/wear_status.dart';
import 'package:olie/features/wear_items/presentation/bloc/wear_item_bloc.dart';
import 'package:olie/features/wear_items/presentation/widgets/wear_gauge.dart';
import 'package:olie/features/wear_items/presentation/widgets/wear_item_row.dart';
import 'package:olie/features/wear_items/presentation/widgets/wear_item_sheets.dart';

/// Itens que se desgastam, do mais urgente ao que está guardado.
///
/// O filtro por status é local: o bloc mantém a lista completa porque a
/// aba Hoje também lê dela.
class WearItemsView extends StatefulWidget {
  const WearItemsView({super.key});

  @override
  State<WearItemsView> createState() => _WearItemsViewState();
}

class _WearItemsViewState extends State<WearItemsView> {
  final Set<WearStatus> _filter = {};

  void _toggle(WearStatus status) {
    setState(() {
      if (!_filter.remove(status)) _filter.add(status);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WearItemBloc, WearItemState>(
      builder: (context, state) {
        if (state.status == WearItemStatus.loading && state.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.items.isEmpty) {
          return const EmptyHint(
            title: 'Nenhum item cadastrado.',
            hint:
                'Cadastre o que precisa ser trocado de tempos em tempos '
                '(filtro de água, pneus, escova de dentes) e o Olie calcula '
                'quando trocar.',
          );
        }

        final counts = {
          for (final status in WearStatus.values)
            status: state.items
                .where((i) => i.estimate.status == status)
                .length,
        };
        final items =
            state.items
                .where(
                  (i) => _filter.isEmpty || _filter.contains(i.estimate.status),
                )
                .toList()
              ..sort((a, b) => a.sortKey.compareTo(b.sortKey));

        return ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Row(
                children: [
                  for (final status in const [
                    WearStatus.overdue,
                    WearStatus.nearEnd,
                    WearStatus.ok,
                    WearStatus.inStock,
                  ]) ...[
                    _StatusChip(
                      status: status,
                      count: counts[status]!,
                      selected: _filter.contains(status),
                      onTap: () => _toggle(status),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            if (items.isEmpty)
              const EmptyHint(title: 'Nenhum item com esse status.'),
            for (final item in items) ...[
              WearItemRow(
                key: ValueKey(item.id),
                item: item,
                onTap: () => showWearItemSheet(context, item),
              ),
              const Divider(indent: 20),
            ],
          ],
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  final WearStatus status;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.status,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = OliePalette.of(context);
    return FilterChip(
      selected: selected,
      onSelected: (_) => onTap(),
      avatar: CircleAvatar(radius: 4, backgroundColor: status.tone.color(p)),
      label: Text('${status.label}  $count'),
    );
  }
}
