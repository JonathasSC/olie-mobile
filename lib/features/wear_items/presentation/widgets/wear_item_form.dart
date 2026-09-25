import 'package:flutter/material.dart';

import 'package:olie/features/wear_items/domain/entities/lifespan_unit.dart';
import 'package:olie/features/wear_items/presentation/widgets/wear_date_field.dart';
import 'package:olie/features/wear_items/presentation/widgets/wear_formatters.dart';

typedef WearItemFormSubmit =
    void Function({
      required String name,
      required int expectedLifespan,
      required LifespanUnit expectedLifespanUnit,
      required DateTime purchaseDate,
      DateTime? installationDate,
      double? purchaseValue,
    });

class WearItemForm extends StatefulWidget {
  final String? initialName;
  final int? initialExpectedLifespan;
  final LifespanUnit initialExpectedLifespanUnit;
  final DateTime? initialPurchaseDate;
  final DateTime? initialInstallationDate;

  /// Na edição, reflete se o ciclo atual já foi instalado; no cadastro,
  /// assume que o item já está em uso.
  final bool initialInstalled;
  final double? initialPurchaseValue;
  final String submitLabel;
  final WearItemFormSubmit onSubmit;
  final VoidCallback onCancel;

  const WearItemForm({
    super.key,
    this.initialName,
    this.initialExpectedLifespan,
    this.initialExpectedLifespanUnit = LifespanUnit.months,
    this.initialPurchaseDate,
    this.initialInstallationDate,
    this.initialInstalled = true,
    this.initialPurchaseValue,
    required this.submitLabel,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  State<WearItemForm> createState() => _WearItemFormState();
}

class _WearItemFormState extends State<WearItemForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _lifespanController;
  late final TextEditingController _valueController;
  late LifespanUnit _unit;
  late DateTime _purchaseDate;
  late bool _installed;
  late DateTime _installationDate;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final today = DateUtils.dateOnly(DateTime.now());
    _nameController = TextEditingController(text: widget.initialName);
    _lifespanController = TextEditingController(
      text: widget.initialExpectedLifespan?.toString(),
    );
    _valueController = TextEditingController(
      text: widget.initialPurchaseValue?.toStringAsFixed(2),
    );
    _unit = widget.initialExpectedLifespanUnit;
    _purchaseDate = widget.initialPurchaseDate ?? today;
    _installed = widget.initialInstalled;
    _installationDate = widget.initialInstallationDate ?? _purchaseDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lifespanController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _onPurchaseDateChanged(DateTime date) {
    setState(() {
      _purchaseDate = date;
      if (_installationDate.isBefore(date)) _installationDate = date;
    });
  }

  void _submit() {
    final name = _nameController.text.trim();
    final lifespan = int.tryParse(_lifespanController.text.trim());
    final rawValue = _valueController.text.trim();
    final value = rawValue.isEmpty ? null : parseWearValue(rawValue);

    if (name.isEmpty) {
      setState(() => _errorText = 'Informe um nome.');
      return;
    }
    if (lifespan == null || lifespan <= 0) {
      setState(() => _errorText = 'Informe uma vida útil válida.');
      return;
    }
    if (rawValue.isNotEmpty && (value == null || value <= 0)) {
      setState(() => _errorText = 'Informe um valor de compra válido.');
      return;
    }
    if (_installed && _installationDate.isBefore(_purchaseDate)) {
      setState(
        () => _errorText = 'A instalação não pode ser anterior à compra.',
      );
      return;
    }

    widget.onSubmit(
      name: name,
      expectedLifespan: lifespan,
      expectedLifespanUnit: _unit,
      purchaseDate: _purchaseDate,
      installationDate: _installed ? _installationDate : null,
      purchaseValue: value,
    );
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
                hintText: 'Filtro de água, pneus, escova de dentes...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _lifespanController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Vida útil esperada',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<LifespanUnit>(
                    initialValue: _unit,
                    decoration: const InputDecoration(
                      labelText: 'Unidade',
                      border: OutlineInputBorder(),
                    ),
                    items: LifespanUnit.values
                        .map(
                          (unit) => DropdownMenuItem(
                            value: unit,
                            child: Text(unit.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _unit = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            WearDateField(
              label: 'Compra',
              value: _purchaseDate,
              onChanged: _onPurchaseDateChanged,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Já está em uso'),
              subtitle: _installed
                  ? null
                  : const Text('Comprado e guardado (em estoque)'),
              value: _installed,
              onChanged: (value) => setState(() => _installed = value),
            ),
            if (_installed)
              WearDateField(
                label: 'Instalação',
                value: _installationDate,
                firstDate: _purchaseDate,
                onChanged: (date) => setState(() => _installationDate = date),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _valueController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Valor de compra (opcional)',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
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
