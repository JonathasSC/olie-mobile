import 'package:flutter/material.dart';

import 'package:olie/features/planned_items/domain/entities/planned_item_priority.dart';

typedef PlannedItemFormSubmit =
    void Function({
      required String name,
      required PlannedItemPriority priority,
      required double estimatedValue,
      required DateTime estimatedDate,
    });

class PlannedItemForm extends StatefulWidget {
  final String? initialName;
  final PlannedItemPriority initialPriority;
  final double? initialEstimatedValue;
  final DateTime? initialEstimatedDate;
  final String submitLabel;
  final PlannedItemFormSubmit onSubmit;
  final VoidCallback onCancel;

  const PlannedItemForm({
    super.key,
    this.initialName,
    this.initialPriority = PlannedItemPriority.essential,
    this.initialEstimatedValue,
    this.initialEstimatedDate,
    required this.submitLabel,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  State<PlannedItemForm> createState() => _PlannedItemFormState();
}

class _PlannedItemFormState extends State<PlannedItemForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _valueController;
  late PlannedItemPriority _priority;
  DateTime? _date;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _valueController = TextEditingController(
      text: widget.initialEstimatedValue?.toStringAsFixed(2),
    );
    _priority = widget.initialPriority;
    _date = widget.initialEstimatedDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  void _submit() {
    final name = _nameController.text.trim();
    final value = double.tryParse(
      _valueController.text.trim().replaceAll(',', '.'),
    );

    if (name.isEmpty) {
      setState(() => _errorText = 'Informe um nome.');
      return;
    }
    if (value == null || value <= 0) {
      setState(() => _errorText = 'Informe um valor estimado válido.');
      return;
    }
    if (_date == null) {
      setState(() => _errorText = 'Escolha uma data estimada.');
      return;
    }

    widget.onSubmit(
      name: name,
      priority: _priority,
      estimatedValue: value,
      estimatedDate: _date!,
    );
  }

  String _formatDate(DateTime date) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
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
            DropdownButtonFormField<PlannedItemPriority>(
              initialValue: _priority,
              decoration: const InputDecoration(
                labelText: 'Prioridade',
                border: OutlineInputBorder(),
              ),
              items: PlannedItemPriority.values
                  .map(
                    (priority) => DropdownMenuItem(
                      value: priority,
                      child: Text(priority.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _priority = value);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _valueController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Valor estimado',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(
                _date == null
                    ? 'Escolher data estimada'
                    : _formatDate(_date!),
              ),
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
