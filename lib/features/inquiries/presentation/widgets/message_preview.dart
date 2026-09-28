import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:olie/core/theme/app_theme.dart';
import 'package:olie/features/inquiries/presentation/widgets/inquiry_photo_thumbnail.dart';

/// Uma mensagem como o contato vai ver: texto, ou foto com legenda.
class PreviewBubble {
  final String text;
  final bool isPhoto;
  final String? photoId;
  final Uint8List? localBytes;

  const PreviewBubble.text(this.text)
    : isPhoto = false,
      photoId = null,
      localBytes = null;

  const PreviewBubble.photo(this.text, {this.photoId, this.localBytes})
    : isPhoto = true;
}

/// Sequência de mensagens no estilo de conversa.
class MessagePreview extends StatelessWidget {
  final List<PreviewBubble> bubbles;

  const MessagePreview({super.key, required this.bubbles});

  @override
  Widget build(BuildContext context) {
    final p = OliePalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final bubble in bubbles)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: p.oliveSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (bubble.isPhoto) ...[
                        InquiryPhotoThumbnail(
                          photoId: bubble.photoId,
                          localBytes: bubble.localBytes,
                          size: 160,
                        ),
                        const SizedBox(height: 6),
                      ],
                      Text(
                        bubble.text,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
