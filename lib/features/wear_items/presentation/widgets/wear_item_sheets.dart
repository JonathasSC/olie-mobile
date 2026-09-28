import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:olie/core/presentation/formatters.dart';
import 'package:olie/core/presentation/olie_widgets.dart';
import 'package:olie/core/theme/app_theme.dart';
import 'package:olie/features/wear_items/domain/entities/wear_item.dart';
import 'package:olie/features/wear_items/domain/entities/wear_status.dart';
import 'package:olie/features/wear_items/presentation/bloc/wear_item_bloc.dart';
import 'package:olie/features/wear_items/presentation/widgets/wear_formatters.dart';
import 'package:olie/features/wear_items/presentation/widgets/wear_gauge.dart';
import 'package:olie/features/wear_items/presentation/widgets/wear_item_form.dart';
import 'package:olie/features/wear_items/presentation/widgets/wear_item_history.dart';
import 'package:olie/features/wear_items/presentation/widgets/wear_item_replace_form.dart';

/// Painel de cadastro de um item de desgaste.
Future<void> showNewWearItemSheet(BuildContext context) {
  final bloc = context.read<WearItemBloc>();
  return showOlieSheet(
    context,
    eyebrow: 'Desgaste',
    title: 'Novo item',
    builder: (sheetContext) => WearItemForm(
      submitLabel: 'Adicionar',
      onCancel: () => Navigator.of(sheetContext).pop(),
      onSubmit:
          ({
            required name,
            required expectedLifespan,
            required expectedLifespanUnit,
            required purchaseDate,
            installationDate,
            purchaseValue,
          }) {
            Navigator.of(sheetContext).pop();
            bloc.add(
              WearItemAdded(
                name: name,
                expectedLifespan: expectedLifespan,
                expectedLifespanUnit: expectedLifespanUnit,
                purchaseDate: purchaseDate,
                installationDate: installationDate,
                purchaseValue: purchaseValue,
              ),
            );
          },
    ),
  );
}

/// Painel com o estado de um item, histórico de trocas e ações.
Future<void> showWearItemSheet(BuildContext context, WearItem item) {
  final bloc = context.read<WearItemBloc>();
  return showOlieSheet(
    context,
    eyebrow: 'Desgaste · ${item.estimate.status.label}',
    title: item.name,
    builder: (_) => BlocProvider.value(
      value: bloc,
      child: _WearItemDetail(itemId: item.id, fallback: item),
    ),
  );
}

enum _Mode { detail, editing, replacing }

class _WearItemDetail extends StatefulWidget {
  final String itemId;

  /// Usado enquanto o item não está (ou deixou de estar) na lista do bloc.
  final WearItem fallback;

  const _WearItemDetail({required this.itemId, required this.fallback});

  @override
  State<_WearItemDetail> createState() => _WearItemDetailState();
}

class _WearItemDetailState extends State<_WearItemDetail> {
  _Mode _mode = _Mode.detail;
  bool _showHistory = false;

  void _close() => Navigator.of(context).pop();

  void _toggleHistory(WearItemState state) {
    setState(() => _showHistory = !_showHistory);
    if (_showHistory && state.histories[widget.itemId] == null) {
      context.read<WearItemBloc>().add(WearItemHistoryRequested(widget.itemId));
    }
  }

  Future<void> _delete(WearItem item) async {
    final bloc = context.read<WearItemBloc>();
    if (!await confirmDelete(context, item.name)) return;
    bloc.add(WearItemDeleted(item.id));
    if (mounted) _close();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WearItemBloc, WearItemState>(
      builder: (context, state) {
        final item = state.items.firstWhere(
          (candidate) => candidate.id == widget.itemId,
          orElse: () => widget.fallback,
        );
        return switch (_mode) {
          _Mode.editing => _buildEdit(item),
          _Mode.replacing => _buildReplace(item),
          _Mode.detail => _buildDetail(context, item, state),
        };
      },
    );
  }

  Widget _buildEdit(WearItem item) {
    return WearItemForm(
      initialName: item.name,
      initialExpectedLifespan: item.expectedLifespan,
      initialExpectedLifespanUnit: item.expectedLifespanUnit,
      initialPurchaseDate: item.currentCycle.purchaseDate,
      initialInstallationDate: item.currentCycle.installationDate,
      initialInstalled: item.currentCycle.installationDate != null,
      initialPurchaseValue: item.currentCycle.purchaseValue,
      submitLabel: 'Salvar',
      onCancel: () => setState(() => _mode = _Mode.detail),
      onSubmit:
          ({
            required name,
            required expectedLifespan,
            required expectedLifespanUnit,
            required purchaseDate,
            installationDate,
            purchaseValue,
          }) {
            context.read<WearItemBloc>().add(
              WearItemUpdated(
                id: item.id,
                name: name,
                expectedLifespan: expectedLifespan,
                expectedLifespanUnit: expectedLifespanUnit,
                purchaseDate: purchaseDate,
                installationDate: installationDate,
                purchaseValue: purchaseValue,
              ),
            );
            _close();
          },
    );
  }

  Widget _buildReplace(WearItem item) {
    return WearItemReplaceForm(
      item: item,
      onCancel: () => setState(() => _mode = _Mode.detail),
      onSubmit:
          ({
            required purchaseDate,
            installationDate,
            removalDate,
            purchaseValue,
            paymentMethod,
          }) {
            context.read<WearItemBloc>().add(
              WearItemReplaced(
                id: item.id,
                purchaseDate: purchaseDate,
                installationDate: installationDate,
                removalDate: removalDate,
                purchaseValue: purchaseValue,
                paymentMethod: paymentMethod,
              ),
            );
            _close();
          },
    );
  }

  Widget _buildDetail(
    BuildContext context,
    WearItem item,
    WearItemState state,
  ) {
    final p = OliePalette.of(context);
    final estimate = item.estimate;
    final cycle = item.currentCycle;
    final days = estimate.daysRemaining;
    final isStock = estimate.status == WearStatus.inStock;
    // cyclesCount inclui a unidade atual.
    final replacements = item.cyclesCount - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isStock) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  '${estimate.wearPercentage ?? 0}%',
                  style: OlieText.figure(
                    context,
                    size: 48,
                    color: estimate.status.tone.color(p),
                  ),
                ),
              ),
              if (days != null)
                CountdownTag.days(days, tone: estimate.status.tone),
            ],
          ),
          const SizedBox(height: 10),
          WearGauge(
            percentage: estimate.wearPercentage,
            status: estimate.status,
            height: 10,
          ),
          const SizedBox(height: 6),
          Text(
            'da vida útil consumida',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
        ],
        const Divider(),
        if (estimate.estimatedReplacementDate != null)
          FactRow(
            'Troca prevista',
            formatFullDate(estimate.estimatedReplacementDate!),
          ),
        FactRow(
          'Vida útil',
          '${formatDays(estimate.lifespanDays)} (${estimate.source.label})',
        ),
        FactRow('Comprado em', formatFullDate(cycle.purchaseDate)),
        FactRow(
          'Em uso desde',
          cycle.installationDate == null
              ? 'guardado'
              : formatFullDate(cycle.installationDate!),
        ),
        if (cycle.purchaseValue != null)
          FactRow('Valor pago', formatCurrency(cycle.purchaseValue!)),
        if (estimate.suggestedValue != null)
          FactRow(
            'Próxima deve custar',
            '~${formatCurrency(estimate.suggestedValue!)}',
          ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () => setState(() => _mode = _Mode.replacing),
          icon: const Icon(Icons.autorenew),
          label: const Text('Registrar troca'),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _mode = _Mode.editing),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Editar'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: p.critical),
                onPressed: () => _delete(item),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Excluir'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: replacements > 0 ? () => _toggleHistory(state) : null,
          icon: Icon(_showHistory ? Icons.expand_less : Icons.history),
          label: Text(
            replacements == 0
                ? 'Nenhuma troca registrada'
                : _showHistory
                ? 'Ocultar histórico'
                : 'Ver histórico ($replacements '
                      '${replacements == 1 ? 'troca' : 'trocas'})',
          ),
        ),
        if (_showHistory) WearItemHistory(history: state.histories[item.id]),
      ],
    );
  }
}
