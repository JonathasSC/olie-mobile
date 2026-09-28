import 'package:flutter/material.dart';

import 'package:olie/core/presentation/olie_widgets.dart';
import 'package:olie/core/theme/app_theme.dart';
import 'package:olie/features/wear_items/domain/entities/wear_item.dart';
import 'package:olie/features/wear_items/domain/entities/wear_status.dart';

extension WearStatusTone on WearStatus {
  Tone get tone => switch (this) {
    WearStatus.inStock => Tone.muted,
    WearStatus.ok => Tone.calm,
    WearStatus.nearEnd => Tone.warning,
    WearStatus.overdue => Tone.critical,
  };
}

extension WearItemUrgency on WearItem {
  /// Dias até a troca; itens em estoque vão para o fim da fila.
  int get sortKey => estimate.status == WearStatus.inStock
      ? 1 << 30
      : (estimate.daysRemaining ?? 1 << 29);
}

/// Barra de uso da unidade atual: 0% = nova, 100% = fim da vida útil.
class WearGauge extends StatelessWidget {
  final int? percentage;
  final WearStatus status;
  final double height;

  const WearGauge({
    super.key,
    required this.percentage,
    required this.status,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    final p = OliePalette.of(context);
    final value = ((percentage ?? 0) / 100).clamp(0.0, 1.0);
    return Semantics(
      label: percentage == null ? 'Sem uso' : '$percentage% da vida útil',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: p.rule),
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value,
                child: ColoredBox(color: status.tone.color(p)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
