import 'package:flutter/material.dart';

import 'package:olie/features/wear_items/domain/entities/wear_cycle.dart';
import 'package:olie/features/wear_items/presentation/widgets/wear_formatters.dart';

/// Ciclos encerrados de um item; `null` em [history] = ainda carregando.
class WearItemHistory extends StatelessWidget {
  final List<WearCycle>? history;

  const WearItemHistory({super.key, required this.history});

  String _describe(WearCycle cycle) {
    final parts = <String>[
      'Compra ${formatWearDate(cycle.purchaseDate)}',
      if (cycle.installationDate != null)
        'instalado ${formatWearDate(cycle.installationDate!)}'
      else
        'nunca instalado',
      if (cycle.removalDate != null)
        'removido ${formatWearDate(cycle.removalDate!)}',
      if (cycle.purchaseValue != null) formatWearCurrency(cycle.purchaseValue!),
    ];
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (history == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Histórico de trocas', style: textTheme.titleSmall),
          const SizedBox(height: 4),
          if (history!.isEmpty)
            Text(
              'Nenhuma troca registrada ainda.',
              style: textTheme.bodySmall,
            )
          else
            for (final cycle in history!)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.history),
                title: Text(
                  cycle.lifespanDays == null
                      ? 'Sem duração registrada'
                      : 'Durou ${formatDays(cycle.lifespanDays!)}',
                ),
                subtitle: Text(_describe(cycle)),
              ),
        ],
      ),
    );
  }
}
