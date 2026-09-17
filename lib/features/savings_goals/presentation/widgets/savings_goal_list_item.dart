import 'package:flutter/material.dart';

import 'package:olie/features/planned_items/domain/entities/planned_item.dart';
import 'package:olie/features/savings_goals/domain/entities/savings_goal.dart';
import 'package:olie/features/savings_goals/presentation/widgets/savings_goal_form.dart';

class SavingsGoalListItem extends StatefulWidget {
  final SavingsGoal goal;
  final List<PlannedItem> plannedItems;
  final SavingsGoalFormSubmit onSave;
  final VoidCallback onDelete;

  const SavingsGoalListItem({
    super.key,
    required this.goal,
    required this.plannedItems,
    required this.onSave,
    required this.onDelete,
  });

  @override
  State<SavingsGoalListItem> createState() => _SavingsGoalListItemState();
}

class _SavingsGoalListItemState extends State<SavingsGoalListItem> {
  bool _isEditing = false;

  String _formatCurrency(double value) => 'R\$ ${value.toStringAsFixed(2)}';

  String? _linkedPlannedItemName() {
    if (widget.goal.plannedItemId == null) return null;
    for (final item in widget.plannedItems) {
      if (item.id == widget.goal.plannedItemId) return item.name;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      return SavingsGoalForm(
        initialName: widget.goal.name,
        initialAmount: widget.goal.amount,
        initialPeriod: widget.goal.period,
        initialPlannedItemId: widget.goal.plannedItemId,
        plannedItems: widget.plannedItems,
        submitLabel: 'Salvar',
        onCancel: () => setState(() => _isEditing = false),
        onSubmit: ({required name, required amount, required period, plannedItemId}) {
          setState(() => _isEditing = false);
          widget.onSave(
            name: name,
            amount: amount,
            period: period,
            plannedItemId: plannedItemId,
          );
        },
      );
    }

    final linkedName = _linkedPlannedItemName();

    return Dismissible(
      key: ValueKey(widget.goal.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => widget.onDelete(),
      background: Container(
        color: Theme.of(context).colorScheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
      child: ListTile(
        onTap: () => setState(() => _isEditing = true),
        leading: const CircleAvatar(child: Icon(Icons.savings_outlined)),
        title: Text(widget.goal.name),
        subtitle: Text(
          '${_formatCurrency(widget.goal.amount)} · ${widget.goal.period.label}'
          '${linkedName != null ? ' · $linkedName' : ''}',
        ),
      ),
    );
  }
}
