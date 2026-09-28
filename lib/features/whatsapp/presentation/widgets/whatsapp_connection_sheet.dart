import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:olie/core/presentation/olie_widgets.dart';
import 'package:olie/core/theme/app_theme.dart';
import 'package:olie/features/whatsapp/domain/entities/whatsapp_connection.dart';
import 'package:olie/features/whatsapp/presentation/bloc/whatsapp_bloc.dart';

/// Conexão com o WhatsApp: mostra o QR code (que o WhatsApp troca sozinho a
/// cada ~20 s, recebido em tempo real) até a leitura pelo celular.
Future<void> showWhatsAppConnectionSheet(BuildContext context) {
  final bloc = context.read<WhatsAppBloc>();
  return showOlieSheet(
    context,
    eyebrow: 'Consultas',
    title: 'WhatsApp',
    builder: (_) => BlocProvider.value(
      value: bloc,
      child: const _ConnectionPanel(),
    ),
  );
}

class _ConnectionPanel extends StatelessWidget {
  const _ConnectionPanel();

  @override
  Widget build(BuildContext context) {
    final p = OliePalette.of(context);
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<WhatsAppBloc, WhatsAppState>(
      builder: (context, state) {
        final connection = state.connection;
        final bloc = context.read<WhatsAppBloc>();
        final qr = connection.qrCodeBytes;
        final reason = connection.reasonMessage;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FactRow('Status', connection.status.label),
            if (connection.phone != null) FactRow('Número', connection.phone!),
            if (reason != null && !connection.isConnected) ...[
              const SizedBox(height: 8),
              Text(reason, style: textTheme.bodySmall),
            ],
            if (state.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                state.errorMessage!,
                style: textTheme.bodySmall?.copyWith(color: p.critical),
              ),
            ],
            const SizedBox(height: 16),
            if (connection.status == WhatsAppConnectionStatus.waitingQr &&
                qr != null) ...[
              Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.memory(
                      qr,
                      width: 240,
                      height: 240,
                      gaplessPlayback: true,
                      filterQuality: FilterQuality.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'No celular, abra o WhatsApp › Dispositivos conectados › '
                'Conectar dispositivo e aponte a câmera para o código.',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
            ],
            if (connection.status == WhatsAppConnectionStatus.connecting ||
                state.busy)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (connection.isConnected)
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: p.critical),
                onPressed: state.busy
                    ? null
                    : () => bloc.add(const WhatsAppDisconnectRequested()),
                icon: const Icon(Icons.link_off, size: 18),
                label: const Text('Desconectar'),
              )
            else if (connection.status ==
                WhatsAppConnectionStatus.disconnected)
              FilledButton.icon(
                onPressed: state.busy
                    ? null
                    : () => bloc.add(const WhatsAppConnectRequested()),
                icon: const Icon(Icons.qr_code_2),
                label: const Text('Conectar'),
              ),
            const SizedBox(height: 12),
            Text(
              'O WhatsApp Web não é oficial: envios automáticos podem levar ao '
              'bloqueio do número. Prefira um número dedicado.',
              style: textTheme.bodySmall,
            ),
          ],
        );
      },
    );
  }
}
