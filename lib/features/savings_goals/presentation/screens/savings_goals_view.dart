import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:olie/core/presentation/formatters.dart';
import 'package:olie/core/presentation/olie_widgets.dart';
import 'package:olie/core/theme/app_theme.dart';
import 'package:olie/features/planned_items/domain/entities/planned_item.dart';
import 'package:olie/features/planned_items/presentation/bloc/planned_item_bloc.dart';
import 'package:olie/features/savings_goals/domain/entities/savings_goal.dart';
import 'package:olie/features/savings_goals/presentation/bloc/savings_goal_bloc.dart';
import 'package:olie/features/savings_goals/presentation/widgets/savings_goal_form.dart';
import 'package:olie/features/savings_goals/presentation/widgets/savings_goal_pace.dart';

/// Metas de economia, com o total guardado por mês no topo.
class SavingsGoalsView extends StatelessWidget {
  const SavingsGoalsView({super.key});

  @override
  Widget build(BuildContext context) {
    final plannedItems = context.select<PlannedItemBloc, List<PlannedItem>>(
      (bloc) => bloc.state.items,
    );

    return BlocBuilder<SavingsGoalBloc, SavingsGoalState>(
      builder: (context, state) {
        if (state.status == SavingsGoalStatus.loading && state.goals.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.goals.isEmpty) {
          return const EmptyHint(
            title: 'Nenhuma meta de economia.',
            hint:
                'Defina quanto guardar por dia, semana ou mês. Vincule a '
                'uma compra para ver se o ritmo fecha até a data.',
          );
        }

        final monthly = state.goals.fold<double>(
          0,
          (total, goal) => total + goal.monthlyAmount,
        );
        final p = OliePalette.of(context);

        return ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('GUARDANDO POR MÊS', style: OlieText.label(context)),
                  const SizedBox(height: 4),
                  Text(
                    formatCurrency(monthly),
                    style: OlieText.figure(context, size: 44, color: p.money),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Soma de ${state.goals.length} '
                    '${state.goals.length == 1 ? 'meta' : 'metas'}, '
                    'convertidas para o equivalente mensal.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SectionLabel('Metas'),
            for (final goal in state.goals) ...[
              _GoalRow(
                key: ValueKey(goal.id),
                goal: goal,
                linkedItem: _find(plannedItems, goal.plannedItemId),
                onTap: () => showSavingsGoalSheet(context, goal),
              ),
              const Divider(indent: 20),
            ],
          ],
        );
      },
    );
  }
}

PlannedItem? _find(List<PlannedItem> items, String? id) {
  if (id == null) return null;
  for (final item in items) {
    if (item.id == id) return item;
  }
  return null;
}

class _GoalRow extends StatelessWidget {
  final SavingsGoal goal;
  final PlannedItem? linkedItem;
  final VoidCallback onTap;

  const _GoalRow({
    super.key,
    required this.goal,
    required this.linkedItem,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = OliePalette.of(context);
    final pace = SavingsPace.of(goal, linkedItem);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (linkedItem != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Para ${linkedItem!.name} · '
                      '${formatCurrency(linkedItem!.estimatedValue)} '
                      'até ${formatShortDate(linkedItem!.estimatedDate)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  if (pace != null) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Pill(
                          pace.onTime ? 'No prazo' : 'Não fecha',
                          tone: pace.onTime ? Tone.calm : Tone.warning,
                        ),
                        Text(
                          'junta em ${pace.neededLabel}',
                          style: OlieText.data(context, size: 12),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatCurrency(goal.amount),
                  style: OlieText.data(
                    context,
                    size: 15,
                    color: p.money,
                    weight: FontWeight.w600,
                  ),
                ),
                Text(
                  goal.period.suffix,
                  style: OlieText.data(context, size: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Painel de cadastro de uma meta.
Future<void> showNewSavingsGoalSheet(BuildContext context) {
  final bloc = context.read<SavingsGoalBloc>();
  final plannedItems = context.read<PlannedItemBloc>().state.items;
  return showOlieSheet(
    context,
    eyebrow: 'Metas',
    title: 'Nova meta',
    builder: (sheetContext) => SavingsGoalForm(
      plannedItems: plannedItems,
      submitLabel: 'Adicionar',
      onCancel: () => Navigator.of(sheetContext).pop(),
      onSubmit:
          ({required name, required amount, required period, plannedItemId}) {
            Navigator.of(sheetContext).pop();
            bloc.add(
              SavingsGoalAdded(
                name: name,
                amount: amount,
                period: period,
                plannedItemId: plannedItemId,
              ),
            );
          },
    ),
  );
}

/// Painel de edição de uma meta, com exclusão.
Future<void> showSavingsGoalSheet(BuildContext context, SavingsGoal goal) {
  final bloc = context.read<SavingsGoalBloc>();
  final plannedItems = context.read<PlannedItemBloc>().state.items;
  final p = OliePalette.of(context);
  return showOlieSheet(
    context,
    eyebrow: 'Meta · ${goal.period.label}',
    title: goal.name,
    builder: (sheetContext) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SavingsGoalForm(
          initialName: goal.name,
          initialAmount: goal.amount,
          initialPeriod: goal.period,
          initialPlannedItemId: goal.plannedItemId,
          plannedItems: plannedItems,
          submitLabel: 'Salvar',
          onCancel: () => Navigator.of(sheetContext).pop(),
          onSubmit:
              ({
                required name,
                required amount,
                required period,
                plannedItemId,
              }) {
                Navigator.of(sheetContext).pop();
                bloc.add(
                  SavingsGoalUpdated(
                    id: goal.id,
                    name: name,
                    amount: amount,
                    period: period,
                    plannedItemId: plannedItemId,
                  ),
                );
              },
        ),
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: p.critical),
            onPressed: () async {
              if (!await confirmDelete(sheetContext, goal.name)) return;
              bloc.add(SavingsGoalDeleted(goal.id));
              if (sheetContext.mounted) Navigator.of(sheetContext).pop();
            },
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Excluir meta'),
          ),
        ),
      ],
    ),
  );
}
