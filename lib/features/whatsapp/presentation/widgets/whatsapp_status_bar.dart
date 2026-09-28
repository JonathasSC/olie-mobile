import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:olie/core/presentation/olie_widgets.dart';
import 'package:olie/core/theme/app_theme.dart';
import 'package:olie/features/whatsapp/domain/entities/whatsapp_connection.dart';
import 'package:olie/features/whatsapp/presentation/bloc/whatsapp_bloc.dart';
import 'package:olie/features/whatsapp/presentation/widgets/whatsapp_connection_sheet.dart';

extension WhatsAppConnectionTone on WhatsAppConnectionStatus {
  Tone get tone => switch (this) {
    WhatsAppConnectionStatus.connected => Tone.calm,
    WhatsAppConnectionStatus.connecting => Tone.warning,
    WhatsAppConnectionStatus.waitingQr => Tone.warning,
    WhatsAppConnectionStatus.disconnected => Tone.critical,
  };
}

/// Faixa com o estado do WhatsApp; toque abre o painel de conexão.
class WhatsAppStatusBar extends StatelessWidget {
  const WhatsAppStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final p = OliePalette.of(context);
    return BlocBuilder<WhatsAppBloc, WhatsAppState>(
      builder: (context, state) {
        final connection = state.connection;
        final tone = connection.status.tone;
        final detail = connection.isConnected
            ? connection.phone ?? ''
            : 'Toque para conectar';
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: Material(
            color: tone.soft(p),
            borderRadius: BorderRadius.circular(6),
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () => showWhatsAppConnectionSheet(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    CircleAvatar(radius: 4, backgroundColor: tone.color(p)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'WhatsApp · ${connection.status.label}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(detail, style: OlieText.data(context, size: 12)),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right, size: 18, color: p.muted),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
