import 'package:flutter/material.dart';

import 'package:olie/features/wear_items/presentation/widgets/wear_formatters.dart';

/// Botão que abre o seletor de data. As datas da API de desgaste não podem
/// ser futuras, então o limite superior padrão é hoje.
class WearDateField extends StatelessWidget {
  final String label;
  final DateTime? value;

  /// Texto exibido quando [value] é `null`.
  final String emptyText;
  final ValueChanged<DateTime> onChanged;

  /// Quando informado, exibe um botão para limpar a data.
  final VoidCallback? onClear;
  final DateTime? firstDate;

  const WearDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.emptyText = 'Escolher data',
    this.onClear,
    this.firstDate,
  });

  Future<void> _pick(BuildContext context) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final first = firstDate ?? DateTime(today.year - 20);
    var initial = value ?? today;
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(today)) initial = today;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: today,
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pick(context),
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text(
              '$label: ${value == null ? emptyText : formatWearDate(value!)}',
            ),
          ),
        ),
        if (onClear != null && value != null)
          IconButton(
            tooltip: 'Limpar',
            icon: const Icon(Icons.clear),
            onPressed: onClear,
          ),
      ],
    );
  }
}
