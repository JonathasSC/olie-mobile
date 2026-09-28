import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:olie/core/presentation/formatters.dart';
import 'package:olie/core/presentation/olie_widgets.dart';
import 'package:olie/core/theme/app_theme.dart';
import 'package:olie/features/planned_items/domain/entities/planned_item.dart';
import 'package:olie/features/planned_items/presentation/bloc/planned_item_bloc.dart';
import 'package:olie/features/planned_items/presentation/widgets/planned_item_complete_form.dart';
import 'package:olie/features/planned_items/presentation/widgets/planned_item_form.dart';
import 'package:olie/features/savings_goals/presentation/bloc/savings_goal_bloc.dart';

/// Painel de cadastro de uma compra planejada.
Future<void> showNewPlannedItemSheet(BuildContext context) {
  final bloc = context.read<PlannedItemBloc>();
  return showOlieSheet(
    context,
    eyebrow: 'Compras',
    title: 'Nova compra',
    builder: (sheetContext) => PlannedItemForm(
      submitLabel: 'Adicionar',
      onCancel: () => Navigator.of(sheetContext).pop(),
      onSubmit:
          ({
            required name,
            required priority,
            required estimatedValue,
            required estimatedDate,
          }) {
            Navigator.of(sheetContext).pop();
            bloc.add(
              PlannedItemAdded(
                name: name,
                priority: priority,
                estimatedValue: estimatedValue,
                estimatedDate: estimatedDate,
              ),
            );
          },
    ),
  );
}

/// Painel com os detalhes de uma compra e as ações sobre ela.
Future<void> showPlannedItemSheet(BuildContext context, PlannedItem item) {
  final plannedItemBloc = context.read<PlannedItemBloc>();
  final savingsGoalBloc = context.read<SavingsGoalBloc>();
  return showOlieSheet(
    context,
    eyebrow: 'Compra planejada · ${item.priority.label}',
    title: item.name,
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: plannedItemBloc),
        BlocProvider.value(value: savingsGoalBloc),
      ],
      child: _PlannedItemDetail(item: item),
    ),
  );
}

enum _Mode { detail, editing, completing }

class _PlannedItemDetail extends StatefulWidget {
  final PlannedItem item;

  const _PlannedItemDetail({required this.item});

  @override
  State<_PlannedItemDetail> createState() => _PlannedItemDetailState();
}

class _PlannedItemDetailState extends State<_PlannedItemDetail> {
  _Mode _mode = _Mode.detail;

  PlannedItem get item => widget.item;

  void _close() => Navigator.of(context).pop();

  Future<void> _delete() async {
    final bloc = context.read<PlannedItemBloc>();
    if (!await confirmDelete(context, item.name)) return;
    bloc.add(PlannedItemDeleted(item.id));
    if (mounted) _close();
  }

  @override
  Widget build(BuildContext context) {
    switch (_mode) {
      case _Mode.editing:
        return PlannedItemForm(
          initialName: item.name,
          initialPriority: item.priority,
          initialEstimatedValue: item.estimatedValue,
          initialEstimatedDate: item.estimatedDate,
          submitLabel: 'Salvar',
          onCancel: () => setState(() => _mode = _Mode.detail),
          onSubmit:
              ({
                required name,
                required priority,
                required estimatedValue,
                required estimatedDate,
              }) {
                context.read<PlannedItemBloc>().add(
                  PlannedItemUpdated(
                    id: item.id,
                    name: name,
                    priority: priority,
                    estimatedValue: estimatedValue,
                    estimatedDate: estimatedDate,
                  ),
                );
                _close();
              },
        );
      case _Mode.completing:
        return PlannedItemCompleteForm(
          estimatedValue: item.estimatedValue,
          onCancel: () => setState(() => _mode = _Mode.detail),
          onSubmit: ({required paymentMethod, value}) {
            context.read<PlannedItemBloc>().add(
              PlannedItemCompleted(
                id: item.id,
                paymentMethod: paymentMethod,
                value: value,
              ),
            );
            _close();
          },
        );
      case _Mode.detail:
        return _buildDetail(context);
    }
  }

  Widget _buildDetail(BuildContext context) {
    final p = OliePalette.of(context);
    final days = daysUntil(item.estimatedDate);
    final goals = context
        .watch<SavingsGoalBloc>()
        .state
        .goals
        .where((goal) => goal.plannedItemId == item.id)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                formatCurrency(item.estimatedValue),
                style: OlieText.figure(context, size: 40, color: p.money),
              ),
            ),
            CountdownTag.days(days, tone: toneForDays(days, calm: Tone.money)),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(),
        FactRow('Data prevista', formatFullDate(item.estimatedDate)),
        FactRow('Prazo', formatRelativeDays(days)),
        FactRow('Prioridade', item.priority.label),
        for (final goal in goals)
          FactRow(
            'Meta "${goal.name}"',
            '${formatCurrency(goal.amount)} · ${goal.period.label}',
          ),
        if (goals.isEmpty) const FactRow('Metas vinculadas', 'nenhuma'),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () => setState(() => _mode = _Mode.completing),
          icon: const Icon(Icons.shopping_bag_outlined),
          label: const Text('Efetivar compra'),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _mode = _Mode.editing),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Editar'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: p.critical),
                onPressed: _delete,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Excluir'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
