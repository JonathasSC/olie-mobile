import 'dart:async';

import 'package:flutter/material.dart';

/// Contagem regressiva até [target], atualizada a cada segundo ("0:42").
class CountdownText extends StatefulWidget {
  final DateTime target;
  final TextStyle? style;

  const CountdownText({super.key, required this.target, this.style});

  @override
  State<CountdownText> createState() => _CountdownTextState();
}

class _CountdownTextState extends State<CountdownText> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.target.difference(DateTime.now());
    final seconds = remaining.isNegative ? 0 : remaining.inSeconds;
    final text = '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
    return Text(text, style: widget.style);
  }
}
