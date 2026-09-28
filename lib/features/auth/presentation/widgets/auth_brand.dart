import 'package:flutter/material.dart';

import 'package:olie/core/theme/app_theme.dart';

/// Marca do Olie nas telas de entrada: nome, frase e o título da tela.
class AuthBrand extends StatelessWidget {
  final String title;

  const AuthBrand({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final p = OliePalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'olie',
          style: Theme.of(context).textTheme.displayLarge
              ?.copyWith(color: p.olive, fontSize: 88, height: 0.9),
        ),
        const SizedBox(height: 8),
        Text(
          'Compras, trocas e metas da casa, com prazo.',
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: p.muted),
        ),
        const SizedBox(height: 32),
        Text(title.toUpperCase(), style: OlieText.label(context)),
      ],
    );
  }
}
