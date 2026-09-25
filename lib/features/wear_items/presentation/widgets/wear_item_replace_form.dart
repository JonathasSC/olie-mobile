import 'package:flutter/material.dart';

import 'package:olie/features/wear_items/domain/entities/wear_item.dart';
import 'package:olie/features/wear_items/presentation/widgets/wear_date_field.dart';
import 'package:olie/features/wear_items/presentation/widgets/wear_formatters.dart';

typedef WearItemReplaceSubmit =
    void Function({
      required DateTime purchaseDate,
      DateTime? installationDate,
      DateTime? removalDate,
      double? purchaseValue,
      String? paymentMethod,
    });

class WearItemReplaceForm extends StatefulWidget {
  final WearItem item;
  final WearItemReplaceSubmit onSubmit;
  final VoidCallback onCancel;

  const WearItemReplaceForm({
    super.key,
    required this.item,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  State<WearItemReplaceForm> createState() => _WearItemReplaceFormState();
}

class _WearItemReplaceFormState extends State<WearItemReplaceForm> {
  late final TextEditingController _valueController;
  late final TextEditingController _paymentMethodController;
  late DateTime _purchaseDate;
  bool _installed = true;
  late DateTime _installationDate;
  DateTime? _removalDate;
  String? _errorText;

  /// A unidade antiga não pode sair de uso antes de ter começado.
  DateTime get _currentCycleStart =>
      widget.item.currentCycle.installationDate ??
      widget.item.currentCycle.purchaseDate;

  @override
  void initState() {
    super.initState();
    final today = DateUtils.dateOnly(DateTime.now());
    _purchaseDate = today;
    _installationDate = today;
    _valueController = TextEditingController(
      text: widget.item.estimate.suggestedValue?.toStringAsFixed(2),
    );
    _paymentMethodController = TextEditingController();
  }

  @override
  void dispose() {
    _valueController.dispose();
    _paymentMethodController.dispose();
    super.dispose();
  }

  void _onPurchaseDateChanged(DateTime date) {
    setState(() {
      _purchaseDate = date;
      if (_installationDate.isBefore(date)) _installationDate = date;
    });
  }

  void _submit() {
    final rawValue = _valueController.text.trim();
    final value = rawValue.isEmpty ? null : parseWearValue(rawValue);
    final paymentMethod = _paymentMethodController.text.trim();

    if (rawValue.isNotEmpty && (value == null || value <= 0)) {
      setState(() => _errorText = 'Informe um valor pago válido.');
      return;
    }
    if (paymentMethod.isNotEmpty && value == null) {
      setState(
        () => _errorText =
            'Informe o valor pago para registrar a forma de pagamento.',
      );
      return;
    }
    if (_installed && _installationDate.isBefore(_purchaseDate)) {
      setState(
        () => _errorText = 'A instalação não pode ser anterior à compra.',
      );
      return;
    }

    // Sem data explícita, a API usa a instalação da nova unidade ou hoje —
    // checamos essa data efetiva contra o início do ciclo atual.
    final effectiveRemoval =
        _removalDate ??
        (_installed
            ? _installationDate
            : DateUtils.dateOnly(DateTime.now()));
    if (effectiveRemoval.isBefore(_currentCycleStart)) {
      setState(
        () => _errorText =
            'A unidade antiga não pode sair de uso antes de '
            '${formatWearDate(_currentCycleStart)}.',
      );
      return;
    }

    widget.onSubmit(
      purchaseDate: _purchaseDate,
      installationDate: _installed ? _installationDate : null,
      removalDate: _removalDate,
      purchaseValue: value,
      paymentMethod: paymentMethod.isEmpty ? null : paymentMethod,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Registrar troca · ${widget.item.name}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          WearDateField(
            label: 'Compra da nova',
            value: _purchaseDate,
            onChanged: _onPurchaseDateChanged,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Nova unidade já instalada'),
            subtitle: _installed
                ? null
                : const Text('Comprada e guardada (em estoque)'),
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
          const SizedBox(height: 8),
          WearDateField(
            label: 'Saída da antiga',
            value: _removalDate,
            emptyText: _installed ? 'na instalação' : 'hoje',
            firstDate: _currentCycleStart,
            onChanged: (date) => setState(() => _removalDate = date),
            onClear: () => setState(() => _removalDate = null),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _valueController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Valor pago (opcional)',
              prefixText: 'R\$ ',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _paymentMethodController,
            decoration: const InputDecoration(
              labelText: 'Forma de pagamento (opcional)',
              hintText: 'Informe para lançar a despesa',
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
              FilledButton(onPressed: _submit, child: const Text('Confirmar')),
            ],
          ),
        ],
      ),
    );
  }
}
