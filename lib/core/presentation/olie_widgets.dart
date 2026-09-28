import 'package:flutter/material.dart';

import 'package:olie/core/theme/app_theme.dart';

/// Estado de prazo de um item — decide a cor das etiquetas e marcas.
enum Tone { calm, money, warning, critical, muted }

extension ToneColors on Tone {
  Color color(OliePalette p) => switch (this) {
    Tone.calm => p.olive,
    Tone.money => p.money,
    Tone.warning => p.warning,
    Tone.critical => p.critical,
    Tone.muted => p.muted,
  };

  Color soft(OliePalette p) => switch (this) {
    Tone.calm => p.oliveSoft,
    Tone.money => p.moneySoft,
    Tone.warning => p.warningSoft,
    Tone.critical => p.criticalSoft,
    Tone.muted => p.rule,
  };
}

/// Tom de um prazo em dias: atrasado, próximo (até 7 dias) ou tranquilo.
Tone toneForDays(int days, {Tone calm = Tone.calm}) {
  if (days < 0) return Tone.critical;
  if (days <= 7) return Tone.warning;
  return calm;
}

/// Rótulo de seção: texto mono em caixa-alta com ação opcional à direita.
class SectionLabel extends StatelessWidget {
  final String text;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const SectionLabel(
    this.text, {
    super.key,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(20, 24, 12, 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Text(text.toUpperCase(), style: OlieText.label(context)),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Etiqueta de contagem: número grande + unidade, como etiqueta de prateleira.
///
/// Largura fixa para que as etiquetas de uma lista fiquem alinhadas.
class CountdownTag extends StatelessWidget {
  final String figure;
  final String unit;
  final Tone tone;

  const CountdownTag({
    super.key,
    required this.figure,
    required this.unit,
    required this.tone,
  });

  /// Etiqueta para um prazo em dias ("12 d", "HOJE", "3 d atraso").
  factory CountdownTag.days(int days, {Tone? tone}) {
    final resolved = tone ?? toneForDays(days);
    if (days == 0) {
      return CountdownTag(figure: 'HOJE', unit: '', tone: resolved);
    }
    return CountdownTag(
      figure: '${days.abs()}',
      unit: days < 0 ? 'de atraso' : (days == 1 ? 'dia' : 'dias'),
      tone: resolved,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = OliePalette.of(context);
    final color = tone.color(p);
    return SizedBox(
      width: 76,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            figure,
            style: OlieText.figure(
              context,
              size: figure.length > 3 ? 22 : 28,
              color: color,
            ),
          ),
          if (unit.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              unit.toUpperCase(),
              textAlign: TextAlign.end,
              style: OlieText.label(context, color: color),
            ),
          ],
        ],
      ),
    );
  }
}

/// Selo pequeno de texto (prioridade, status).
class Pill extends StatelessWidget {
  final String text;
  final Tone tone;

  const Pill(this.text, {super.key, required this.tone});

  @override
  Widget build(BuildContext context) {
    final p = OliePalette.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tone.soft(p),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(
          text.toUpperCase(),
          style: OlieText.label(
            context,
            color: tone == Tone.muted ? p.muted : p.ink,
          ).copyWith(fontSize: 10),
        ),
      ),
    );
  }
}

/// Texto de lista vazia, com uma frase que diz o que fazer.
class EmptyHint extends StatelessWidget {
  final String title;
  final String? hint;

  const EmptyHint({super.key, required this.title, this.hint});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.titleMedium),
          if (hint != null) ...[
            const SizedBox(height: 4),
            Text(hint!, style: textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

/// Abre um painel inferior com título e o conteúdo rolável.
Future<T?> showOlieSheet<T>(
  BuildContext context, {
  required String title,
  String? eyebrow,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      final viewInsets = MediaQuery.viewInsetsOf(sheetContext).bottom;
      return Padding(
        padding: EdgeInsets.only(bottom: viewInsets),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (eyebrow != null) ...[
                  Text(
                    eyebrow.toUpperCase(),
                    style: OlieText.label(sheetContext),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  title,
                  style: Theme.of(sheetContext).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                builder(sheetContext),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Pede confirmação antes de excluir. Retorna `true` se confirmado.
Future<bool> confirmDelete(BuildContext context, String name) async {
  final p = OliePalette.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Excluir "$name"?'),
      content: const Text('Essa ação não pode ser desfeita.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Manter'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: p.critical),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Excluir'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// Linha de fato "rótulo → valor" usada nos painéis de detalhe.
class FactRow extends StatelessWidget {
  final String label;
  final String value;

  const FactRow(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: OlieText.data(context, color: OliePalette.of(context).ink),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mostra um aviso curto no rodapé.
void showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
