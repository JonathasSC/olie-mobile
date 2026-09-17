import 'package:flutter/material.dart';

import 'package:olie/features/planned_items/domain/entities/planned_item.dart';
import 'package:olie/features/savings_goals/domain/entities/savings_goal_period.dart';

typedef SavingsGoalFormSubmit =
    void Function({
      required String name,
      required double amount,
      required SavingsGoalPeriod period,
      String? plannedItemId,
    });

class SavingsGoalForm extends StatefulWidget {
  final String? initialName;
  final double? initialAmount;
  final SavingsGoalPeriod initialPeriod;
  final String? initialPlannedItemId;
  final List<PlannedItem> plannedItems;
  final String submitLabel;
  final SavingsGoalFormSubmit onSubmit;
  final VoidCallback onCancel;

  const SavingsGoalForm({
    super.key,
    this.initialName,
    this.initialAmount,
    this.initialPeriod = SavingsGoalPeriod.monthly,
    this.initialPlannedItemId,
    required this.plannedItems,
    required this.submitLabel,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  State<SavingsGoalForm> createState() => _SavingsGoalFormState();
}

class _SavingsGoalFormState extends State<SavingsGoalForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late SavingsGoalPeriod _period;
  String? _plannedItemId;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _amountController = TextEditingController(
      text: widget.initialAmount?.toStringAsFixed(2),
    );
    _period = widget.initialPeriod;
    _plannedItemId = widget.initialPlannedItemId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    final amount = double.tryParse(
      _amountController.text.trim().replaceAll(',', '.'),
    );

    if (name.isEmpty) {
      setState(() => _errorText = 'Informe um nome.');
      return;
    }
    if (amount == null || amount <= 0) {
      setState(() => _errorText = 'Informe um valor válido.');
      return;
    }

    widget.onSubmit(
      name: name,
      amount: amount,
      period: _period,
      plannedItemId: _plannedItemId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final plannedItemIds = widget.plannedItems.map((item) => item.id).toSet();
    final linkedItemStillExists =
        _plannedItemId == null || plannedItemIds.contains(_plannedItemId);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Valor a guardar por período',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<SavingsGoalPeriod>(
              initialValue: _period,
              decoration: const InputDecoration(
                labelText: 'Período',
                border: OutlineInputBorder(),
              ),
              items: SavingsGoalPeriod.values
                  .map(
                    (period) => DropdownMenuItem(
                      value: period,
                      child: Text(period.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _period = value);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: linkedItemStillExists ? _plannedItemId : null,
              decoration: const InputDecoration(
                labelText: 'Vincular a item planejado (opcional)',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('Nenhum')),
                ...widget.plannedItems.map(
                  (item) => DropdownMenuItem(
                    value: item.id,
                    child: Text(
                      item.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _plannedItemId = value),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorText!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.onCancel,
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _submit,
                  child: Text(widget.submitLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
