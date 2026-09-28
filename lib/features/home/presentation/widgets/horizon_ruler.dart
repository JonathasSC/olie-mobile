import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:olie/core/theme/app_theme.dart';

enum HorizonLane { purchase, replacement }

class HorizonMark {
  /// Dias a partir de hoje; negativos vão para a área de atraso.
  final int days;
  final HorizonLane lane;
  final Color color;

  const HorizonMark({
    required this.days,
    required this.lane,
    required this.color,
  });
}

/// Régua dos próximos [span] dias: compras acima do eixo, trocas abaixo.
///
/// A escala é linear (um dia = uma divisão); o que está atrasado é empilhado
/// numa faixa própria à esquerda do "hoje".
class HorizonRuler extends StatelessWidget {
  final List<HorizonMark> marks;
  final int span;

  const HorizonRuler({super.key, required this.marks, this.span = 30});

  @override
  Widget build(BuildContext context) {
    final purchases = marks.where((m) => m.lane == HorizonLane.purchase).length;
    final replacements = marks.length - purchases;
    return Semantics(
      label: 'Próximos $span dias: $purchases compras e $replacements trocas',
      child: SizedBox(
        height: 124,
        width: double.infinity,
        child: CustomPaint(
          painter: _RulerPainter(
            marks: marks,
            span: span,
            palette: OliePalette.of(context),
          ),
        ),
      ),
    );
  }
}

class _RulerPainter extends CustomPainter {
  final List<HorizonMark> marks;
  final int span;
  final OliePalette palette;

  _RulerPainter({
    required this.marks,
    required this.span,
    required this.palette,
  });

  static const _gutter = 40.0;
  static const _axisY = 54.0;
  static const _labelY = 108.0;
  static const _laneGap = 14.0;
  static const _stackStep = 10.0;
  static const _radius = 4.5;

  @override
  void paint(Canvas canvas, Size size) {
    const right = 8.0;
    final left = _gutter + 8;
    final width = size.width - left - right;
    double xFor(int day) => left + width * (day / span);

    // Faixa de atraso.
    final overdueRect = Rect.fromLTWH(0, 4, _gutter, _labelY - 10);
    canvas.drawRRect(
      RRect.fromRectAndRadius(overdueRect, const Radius.circular(4)),
      Paint()..color = palette.criticalSoft,
    );

    // Eixo e divisões diárias.
    final axis = Paint()
      ..color = palette.muted
      ..strokeWidth = 1;
    canvas.drawLine(Offset(left, _axisY), Offset(left + width, _axisY), axis);
    final minor = Paint()
      ..color = palette.rule
      ..strokeWidth = 1;
    for (var day = 0; day <= span; day++) {
      final x = xFor(day);
      final isWeek = day % 7 == 0;
      canvas.drawLine(
        Offset(x, _axisY - (isWeek ? 7 : 3)),
        Offset(x, _axisY + (isWeek ? 7 : 3)),
        isWeek ? axis : minor,
      );
    }

    // Rótulos das semanas (0, 7, 14, 21, 28) numa linha própria abaixo das marcas.
    for (var day = 0; day <= span; day += 7) {
      _label(
        canvas,
        day == 0 ? 'hoje' : '+$day',
        Offset(xFor(day), _labelY),
        align: day == 0 ? TextAlign.left : TextAlign.center,
        color: day == 0 ? palette.ink : palette.muted,
      );
    }
    _label(
      canvas,
      'atraso',
      Offset(_gutter / 2, _labelY),
      align: TextAlign.center,
      color: palette.critical,
    );

    // Marcas, empilhadas quando caem no mesmo dia e faixa.
    final stacks = <String, int>{};
    for (final mark in [...marks]..sort((a, b) => a.days.compareTo(b.days))) {
      final overdue = mark.days < 0;
      final key = '${overdue ? 'late' : mark.days}-${mark.lane.name}';
      final level = stacks[key] = (stacks[key] ?? -1) + 1;
      if (level > 2) continue;
      final x = overdue ? _gutter / 2 : xFor(math.min(mark.days, span));
      final direction = mark.lane == HorizonLane.purchase ? -1 : 1;
      final y = _axisY + direction * (_laneGap + 6 + level * _stackStep);

      canvas.drawLine(
        Offset(x, _axisY + direction * 8),
        Offset(x, y - direction * _radius),
        Paint()
          ..color = mark.color.withValues(alpha: 0.45)
          ..strokeWidth = 1,
      );
      final fill = Paint()..color = mark.color;
      if (mark.lane == HorizonLane.purchase) {
        canvas.drawCircle(Offset(x, y), _radius, fill);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(x, y),
            width: _radius * 2,
            height: _radius * 2,
          ),
          fill,
        );
      }
    }
  }

  void _label(
    Canvas canvas,
    String text,
    Offset anchor, {
    required TextAlign align,
    required Color color,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: OlieFonts.mono,
          fontSize: 10,
          letterSpacing: 0.6,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = switch (align) {
      TextAlign.center => anchor.dx - painter.width / 2,
      TextAlign.right => anchor.dx - painter.width,
      _ => anchor.dx,
    };
    painter.paint(canvas, Offset(dx, anchor.dy));
  }

  @override
  bool shouldRepaint(_RulerPainter oldDelegate) =>
      oldDelegate.marks != marks ||
      oldDelegate.palette != palette ||
      oldDelegate.span != span;
}
