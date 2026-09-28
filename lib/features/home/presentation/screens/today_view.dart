import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:olie/core/presentation/formatters.dart';
import 'package:olie/core/presentation/olie_widgets.dart';
import 'package:olie/core/theme/app_theme.dart';
import 'package:olie/features/home/presentation/widgets/horizon_ruler.dart';
import 'package:olie/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:olie/features/notifications/presentation/widgets/notification_list_item.dart';
import 'package:olie/features/planned_items/presentation/bloc/planned_item_bloc.dart';
import 'package:olie/features/planned_items/presentation/widgets/planned_item_sheets.dart';
import 'package:olie/features/todo/presentation/widgets/todo_section.dart';
import 'package:olie/features/wear_items/domain/entities/wear_status.dart';
import 'package:olie/features/wear_items/presentation/bloc/wear_item_bloc.dart';
import 'package:olie/features/wear_items/presentation/widgets/wear_gauge.dart';
import 'package:olie/features/wear_items/presentation/widgets/wear_item_sheets.dart';

const _horizonDays = 30;

/// Um prazo na fila do dia — compra ou troca.
class _Entry {
  final String kind;
  final String name;
  final String detail;
  final int days;
  final Tone tone;
  final HorizonLane lane;
  final VoidCallback onTap;

  const _Entry({
    required this.kind,
    required this.name,
    required this.detail,
    required this.days,
    required this.tone,
    required this.lane,
    required this.onTap,
  });
}

/// Aba inicial: o que vence nos próximos 30 dias, tarefas e avisos.
class TodayView extends StatelessWidget {
  const TodayView({super.key});

  List<_Entry> _entries(BuildContext context) {
    final planned = context.watch<PlannedItemBloc>().state.items;
    final wear = context.watch<WearItemBloc>().state.items;
    final entries = <_Entry>[];

    for (final item in planned) {
      final days = daysUntil(item.estimatedDate);
      if (days > _horizonDays) continue;
      entries.add(
        _Entry(
          kind: 'Compra',
          name: item.name,
          detail:
              '${formatCurrency(item.estimatedValue)} · '
              '${item.priority.label} · ${formatShortDate(item.estimatedDate)}',
          days: days,
          tone: toneForDays(days, calm: Tone.money),
          lane: HorizonLane.purchase,
          onTap: () => showPlannedItemSheet(context, item),
        ),
      );
    }

    for (final item in wear) {
      final days = item.estimate.daysRemaining;
      final date = item.estimate.estimatedReplacementDate;
      if (item.estimate.status == WearStatus.inStock ||
          days == null ||
          date == null ||
          days > _horizonDays) {
        continue;
      }
      entries.add(
        _Entry(
          kind: 'Troca',
          name: item.name,
          detail:
              '${item.estimate.wearPercentage ?? 0}% usado · '
              'trocar ${formatShortDate(date)}',
          days: days,
          tone: item.estimate.status.tone,
          lane: HorizonLane.replacement,
          onTap: () => showWearItemSheet(context, item),
        ),
      );
    }

    return entries..sort((a, b) => a.days.compareTo(b.days));
  }

  @override
  Widget build(BuildContext context) {
    final entries = _entries(context);
    final loading =
        context.select<PlannedItemBloc, bool>(
          (b) => b.state.status == PlannedItemStatus.loading,
        ) ||
        context.select<WearItemBloc, bool>(
          (b) => b.state.status == WearItemStatus.loading,
        );

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        const _Header(),
        _HorizonPanel(entries: entries),
        SectionLabel(
          'Na fila',
          trailing: entries.isEmpty
              ? null
              : Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    '${entries.length} até '
                    '${formatShortDate(DateTime.now().add(const Duration(days: _horizonDays)))}',
                    style: OlieText.data(context, size: 12),
                  ),
                ),
        ),
        if (loading && entries.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (entries.isEmpty)
          const EmptyHint(
            title: 'Nada vence nos próximos 30 dias.',
            hint:
                'Compras planejadas e trocas com prazo aparecem aqui, '
                'da mais urgente para a mais distante.',
          )
        else
          for (final entry in entries) ...[
            _EntryRow(entry: entry),
            const Divider(indent: 20),
          ],
        const TodoSection(),
        const _RecentNotices(),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatTodayEyebrow(DateTime.now()),
                  style: OlieText.label(context),
                ),
                const SizedBox(height: 4),
                Text('Hoje', style: Theme.of(context).textTheme.displayMedium),
              ],
            ),
          ),
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) => IconButton(
              tooltip: 'Avisos',
              onPressed: () =>
                  Navigator.of(context).pushNamed('/notifications'),
              icon: Badge(
                isLabelVisible: state.notifications.isNotEmpty,
                label: Text('${state.notifications.length}'),
                child: const Icon(Icons.notifications_none),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HorizonPanel extends StatelessWidget {
  final List<_Entry> entries;

  const _HorizonPanel({required this.entries});

  @override
  Widget build(BuildContext context) {
    final p = OliePalette.of(context);
    final purchases = entries
        .where((e) => e.lane == HorizonLane.purchase)
        .length;
    final replacements = entries.length - purchases;
    final late = entries.where((e) => e.days < 0).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: p.surface,
          border: Border.all(color: p.rule),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PRÓXIMOS $_horizonDays DIAS',
                style: OlieText.label(context),
              ),
              const SizedBox(height: 4),
              Text(
                '$purchases ${purchases == 1 ? 'compra' : 'compras'} · '
                '$replacements ${replacements == 1 ? 'troca' : 'trocas'}'
                '${late > 0 ? ' · $late ${late == 1 ? 'atrasada' : 'atrasadas'}' : ''}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              HorizonRuler(
                span: _horizonDays,
                marks: [
                  for (final entry in entries)
                    HorizonMark(
                      days: entry.days,
                      lane: entry.lane,
                      color: entry.tone.color(p),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  _Legend(
                    shape: BoxShape.circle,
                    color: p.money,
                    text: 'compra',
                  ),
                  _Legend(
                    shape: BoxShape.rectangle,
                    color: p.olive,
                    text: 'troca',
                  ),
                  _Legend(
                    shape: BoxShape.circle,
                    color: p.warning,
                    text: 'até 7 dias',
                  ),
                  _Legend(
                    shape: BoxShape.circle,
                    color: p.critical,
                    text: 'atrasado',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final BoxShape shape;
  final Color color;
  final String text;

  const _Legend({required this.shape, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: shape),
        ),
        const SizedBox(width: 6),
        Text(text, style: OlieText.data(context, size: 11)),
      ],
    );
  }
}

class _EntryRow extends StatelessWidget {
  final _Entry entry;

  const _EntryRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final p = OliePalette.of(context);
    return InkWell(
      onTap: entry.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.kind.toUpperCase(),
                    style: OlieText.label(
                      context,
                      color: entry.lane == HorizonLane.purchase
                          ? p.money
                          : p.olive,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(entry.detail, style: OlieText.data(context, size: 12)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            CountdownTag.days(entry.days, tone: entry.tone),
          ],
        ),
      ),
    );
  }
}

class _RecentNotices extends StatelessWidget {
  const _RecentNotices();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        if (state.notifications.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionLabel(
              'Avisos recentes',
              trailing: TextButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed('/notifications'),
                child: const Text('Ver todos'),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
            ),
            for (final notification in state.notifications.take(3))
              NotificationListItem(notification: notification),
          ],
        );
      },
    );
  }
}
