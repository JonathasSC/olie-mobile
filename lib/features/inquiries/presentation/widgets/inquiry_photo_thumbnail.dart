import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:olie/core/di/injection_container.dart' as di;
import 'package:olie/core/theme/app_theme.dart';
import 'package:olie/features/inquiries/domain/usecases/get_inquiry_photo.dart';
import 'package:olie/features/inquiries/domain/usecases/inquiry_id_params.dart';

/// Foto de um item. A rota da foto exige o token, então os bytes vêm pelo
/// repositório (que guarda em memória) em vez de `Image.network`.
class InquiryPhotoThumbnail extends StatefulWidget {
  final String? photoId;

  /// Bytes já disponíveis (foto recém-escolhida): dispensa a rede.
  final Uint8List? localBytes;
  final double size;

  const InquiryPhotoThumbnail({
    super.key,
    this.photoId,
    this.localBytes,
    this.size = 56,
  });

  @override
  State<InquiryPhotoThumbnail> createState() => _InquiryPhotoThumbnailState();
}

class _InquiryPhotoThumbnailState extends State<InquiryPhotoThumbnail> {
  Future<Uint8List?>? _bytes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant InquiryPhotoThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.photoId != widget.photoId ||
        oldWidget.localBytes != widget.localBytes) {
      _load();
    }
  }

  void _load() {
    final local = widget.localBytes;
    final id = widget.photoId;
    if (local != null) {
      _bytes = Future.value(local);
    } else if (id != null) {
      _bytes = di.sl<GetInquiryPhoto>()(InquiryIdParams(id)).then(
        (result) => result.fold((_) => null, (bytes) => bytes),
      );
    } else {
      _bytes = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = OliePalette.of(context);
    final placeholder = Container(
      width: widget.size,
      height: widget.size,
      color: p.rule,
      child: Icon(Icons.image_outlined, color: p.muted),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: FutureBuilder<Uint8List?>(
        future: _bytes,
        builder: (context, snapshot) {
          final bytes = snapshot.data;
          if (bytes == null) return placeholder;
          return Image.memory(
            bytes,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.cover,
            gaplessPlayback: true,
          );
        },
      ),
    );
  }
}
