import 'package:flutter/material.dart';

typedef PlannedItemCompleteSubmit =
    void Function({required String paymentMethod, double? value});

class PlannedItemCompleteForm extends StatefulWidget {
  final double estimatedValue;
  final PlannedItemCompleteSubmit onSubmit;
  final VoidCallback onCancel;

  const PlannedItemCompleteForm({
    super.key,
    required this.estimatedValue,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  State<PlannedItemCompleteForm> createState() =>
      _PlannedItemCompleteFormState();
}

class _PlannedItemCompleteFormState extends State<PlannedItemCompleteForm> {
  late final TextEditingController _paymentMethodController;
  late final TextEditingController _valueController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _paymentMethodController = TextEditingController();
    _valueController = TextEditingController(
      text: widget.estimatedValue.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _paymentMethodController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _submit() {
    final paymentMethod = _paymentMethodController.text.trim();
    if (paymentMethod.isEmpty) {
      setState(() => _errorText = 'Informe a forma de pagamento.');
      return;
    }

    final rawValue = _valueController.text.trim();
    final value = rawValue.isEmpty
        ? null
        : double.tryParse(rawValue.replaceAll(',', '.'));
    if (rawValue.isNotEmpty && value == null) {
      setState(() => _errorText = 'Valor inválido.');
      return;
    }

    widget.onSubmit(paymentMethod: paymentMethod, value: value);
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
            'Efetivar compra',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _paymentMethodController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Forma de pagamento',
              hintText: 'Pix, Dinheiro, Cartão de débito...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _valueController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: 'Valor pago',
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
                child: const Text('Confirmar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
