import 'package:flutter/material.dart';

import 'package:olie/features/wear_items/domain/entities/wear_cycle.dart';
import 'package:olie/features/wear_items/domain/entities/wear_item.dart';
import 'package:olie/features/wear_items/domain/entities/wear_status.dart';
import 'package:olie/features/wear_items/presentation/widgets/wear_formatters.dart';
import 'package:olie/features/wear_items/presentation/widgets/wear_item_form.dart';
import 'package:olie/features/wear_items/presentation/widgets/wear_item_history.dart';
import 'package:olie/features/wear_items/presentation/widgets/wear_item_replace_form.dart';

enum _Mode { display, editing, replacing }

enum _Action { edit, replace, history }

class WearItemListItem extends StatefulWidget {
  final WearItem item;

  /// Ciclos encerrados já carregados; `null` se ainda não foram buscados.
  final List<WearCycle>? history;
  final WearItemFormSubmit onSave;
  final WearItemReplaceSubmit onReplace;
  final VoidCallback onHistoryRequested;
  final VoidCallback onDelete;

  const WearItemListItem({
    super.key,
    required this.item,
    required this.history,
    required this.onSave,
    required this.onReplace,
    required this.onHistoryRequested,
    required this.onDelete,
  });

  @override
  State<WearItemListItem> createState() => _WearItemListItemState();
}

class _WearItemListItemState extends State<WearItemListItem> {
  _Mode _mode = _Mode.display;
  bool _showHistory = false;

  @override
  void didUpdateWidget(WearItemListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Uma troca invalida o histórico em cache; se ele estiver aberto,
    // recarrega em vez de ficar carregando para sempre.
    if (_showHistory && widget.history == null && oldWidget.history != null) {
      widget.onHistoryRequested();
    }
  }

  void _setMode(_Mode mode) => setState(() => _mode = mode);

  void _onAction(_Action action) {
    switch (action) {
      case _Action.edit:
        _setMode(_Mode.editing);
      case _Action.replace:
        _setMode(_Mode.replacing);
      case _Action.history:
        setState(() => _showHistory = !_showHistory);
        if (_showHistory && widget.history == null) {
          widget.onHistoryRequested();
        }
    }
  }

  Color _statusColor(ColorScheme scheme, WearStatus status) {
    switch (status) {
      case WearStatus.inStock:
        return scheme.surfaceContainerHighest;
      case WearStatus.ok:
        return scheme.primaryContainer;
      case WearStatus.nearEnd:
        return scheme.tertiaryContainer;
      case WearStatus.overdue:
        return scheme.errorContainer;
    }
  }

  IconData _statusIcon(WearStatus status) {
    switch (status) {
      case WearStatus.inStock:
        return Icons.inventory_2_outlined;
      case WearStatus.ok:
        return Icons.check;
      case WearStatus.nearEnd:
        return Icons.hourglass_bottom;
      case WearStatus.overdue:
        return Icons.priority_high;
    }
  }

  String _replacementText() {
    final estimate = widget.item.estimate;
    final date = estimate.estimatedReplacementDate;
    final days = estimate.daysRemaining;

    if (estimate.status == WearStatus.inStock || date == null || days == null) {
      return 'Comprado em '
          '${formatWearDate(widget.item.currentCycle.purchaseDate)}';
    }

    final when = days > 0
        ? 'faltam ${formatDays(days)}'
        : days == 0
        ? 'trocar hoje'
        : 'atrasado há ${formatDays(-days)}';
    return 'Troca em ${formatWearDate(date)} · $when';
  }

  String _detailText() {
    final estimate = widget.item.estimate;
    final parts = <String>[
      'Vida útil ${formatDays(estimate.lifespanDays)} '
          '(${estimate.source.label})',
      if (estimate.suggestedValue != null)
        'próxima ~${formatWearCurrency(estimate.suggestedValue!)}',
    ];
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    if (_mode == _Mode.editing) {
      return WearItemForm(
        initialName: item.name,
        initialExpectedLifespan: item.expectedLifespan,
        initialExpectedLifespanUnit: item.expectedLifespanUnit,
        initialPurchaseDate: item.currentCycle.purchaseDate,
        initialInstallationDate: item.currentCycle.installationDate,
        initialInstalled: item.currentCycle.installationDate != null,
        initialPurchaseValue: item.currentCycle.purchaseValue,
        submitLabel: 'Salvar',
        onCancel: () => _setMode(_Mode.display),
        onSubmit:
            ({
              required name,
              required expectedLifespan,
              required expectedLifespanUnit,
              required purchaseDate,
              installationDate,
              purchaseValue,
            }) {
              _setMode(_Mode.display);
              widget.onSave(
                name: name,
                expectedLifespan: expectedLifespan,
                expectedLifespanUnit: expectedLifespanUnit,
                purchaseDate: purchaseDate,
                installationDate: installationDate,
                purchaseValue: purchaseValue,
              );
            },
      );
    }

    if (_mode == _Mode.replacing) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: WearItemReplaceForm(
          item: item,
          onCancel: () => _setMode(_Mode.display),
          onSubmit:
              ({
                required purchaseDate,
                installationDate,
                removalDate,
                purchaseValue,
                paymentMethod,
              }) {
                _setMode(_Mode.display);
                widget.onReplace(
                  purchaseDate: purchaseDate,
                  installationDate: installationDate,
                  removalDate: removalDate,
                  purchaseValue: purchaseValue,
                  paymentMethod: paymentMethod,
                );
              },
        ),
      );
    }

    final scheme = Theme.of(context).colorScheme;
    final status = item.estimate.status;
    final wear = item.estimate.wearPercentage;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => widget.onDelete(),
      background: Container(
        color: scheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            onTap: () => _setMode(_Mode.editing),
            leading: Tooltip(
              message: status.label,
              child: CircleAvatar(
                backgroundColor: _statusColor(scheme, status),
                child: Icon(_statusIcon(status)),
              ),
            ),
            title: Text(item.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${status.label} · ${_replacementText()}'),
                if (wear != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: (wear / 100).clamp(0.0, 1.0),
                          color: status == WearStatus.ok
                              ? null
                              : status == WearStatus.overdue
                              ? scheme.error
                              : scheme.tertiary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('$wear%'),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Text(_detailText()),
              ],
            ),
            isThreeLine: true,
            trailing: PopupMenuButton<_Action>(
              tooltip: 'Ações',
              onSelected: _onAction,
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: _Action.replace,
                  child: Text('Registrar troca'),
                ),
                const PopupMenuItem(value: _Action.edit, child: Text('Editar')),
                PopupMenuItem(
                  value: _Action.history,
                  child: Text(
                    _showHistory
                        ? 'Ocultar histórico'
                        // cyclesCount inclui a unidade atual.
                        : 'Ver histórico (${item.cyclesCount - 1} '
                              '${item.cyclesCount == 2 ? 'troca' : 'trocas'})',
                  ),
                ),
              ],
            ),
          ),
          if (_showHistory) WearItemHistory(history: widget.history),
        ],
      ),
    );
  }
}
