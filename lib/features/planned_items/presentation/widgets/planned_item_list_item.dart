import 'package:flutter/material.dart';

import 'package:olie/features/planned_items/domain/entities/planned_item.dart';
import 'package:olie/features/planned_items/domain/entities/planned_item_priority.dart';
import 'package:olie/features/planned_items/presentation/widgets/planned_item_complete_form.dart';
import 'package:olie/features/planned_items/presentation/widgets/planned_item_form.dart';

enum _Mode { display, editing, completing }

class PlannedItemListItem extends StatefulWidget {
  final PlannedItem item;
  final PlannedItemFormSubmit onSave;
  final PlannedItemCompleteSubmit onComplete;
  final VoidCallback onDelete;

  const PlannedItemListItem({
    super.key,
    required this.item,
    required this.onSave,
    required this.onComplete,
    required this.onDelete,
  });

  @override
  State<PlannedItemListItem> createState() => _PlannedItemListItemState();
}

class _PlannedItemListItemState extends State<PlannedItemListItem> {
  _Mode _mode = _Mode.display;

  void _setMode(_Mode mode) => setState(() => _mode = mode);

  String _formatDate(DateTime date) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year}';
  }

  String _formatCurrency(double value) => 'R\$ ${value.toStringAsFixed(2)}';

  Color _priorityColor(BuildContext context, PlannedItemPriority priority) {
    final scheme = Theme.of(context).colorScheme;
    switch (priority) {
      case PlannedItemPriority.essential:
        return scheme.errorContainer;
      case PlannedItemPriority.desirable:
        return scheme.secondaryContainer;
      case PlannedItemPriority.superfluous:
        return scheme.surfaceContainerHighest;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_mode == _Mode.editing) {
      return PlannedItemForm(
        initialName: widget.item.name,
        initialPriority: widget.item.priority,
        initialEstimatedValue: widget.item.estimatedValue,
        initialEstimatedDate: widget.item.estimatedDate,
        submitLabel: 'Salvar',
        onCancel: () => _setMode(_Mode.display),
        onSubmit:
            ({
              required name,
              required priority,
              required estimatedValue,
              required estimatedDate,
            }) {
              _setMode(_Mode.display);
              widget.onSave(
                name: name,
                priority: priority,
                estimatedValue: estimatedValue,
                estimatedDate: estimatedDate,
              );
            },
      );
    }

    if (_mode == _Mode.completing) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: PlannedItemCompleteForm(
          estimatedValue: widget.item.estimatedValue,
          onCancel: () => _setMode(_Mode.display),
          onSubmit: ({required paymentMethod, value}) {
            _setMode(_Mode.display);
            widget.onComplete(paymentMethod: paymentMethod, value: value);
          },
        ),
      );
    }

    return Dismissible(
      key: ValueKey(widget.item.id),
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
        onTap: () => _setMode(_Mode.editing),
        leading: CircleAvatar(
          backgroundColor: _priorityColor(context, widget.item.priority),
          child: Text(widget.item.priority.label.substring(0, 1)),
        ),
        title: Text(widget.item.name),
        subtitle: Text(
          '${_formatCurrency(widget.item.estimatedValue)} · '
          '${_formatDate(widget.item.estimatedDate)} · '
          '${widget.item.priority.label}',
        ),
        trailing: IconButton(
          tooltip: 'Efetivar compra',
          icon: const Icon(Icons.check_circle_outline),
          onPressed: () => _setMode(_Mode.completing),
        ),
      ),
    );
  }
}
