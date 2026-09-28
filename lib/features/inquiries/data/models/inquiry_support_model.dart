import 'package:olie/features/inquiries/domain/entities/inquiry_support.dart';

abstract final class InquirySupportModel {
  static InquirySettings settingsFromJson(Map<String, dynamic> json) {
    int value(String key) => (json[key] as num).toInt();
    return InquirySettings(
      messageTemplate: json['messageTemplate'] as String,
      timezone: json['timezone'] as String,
      maxItems: value('maxItems'),
      maxRecipients: value('maxRecipients'),
      contactIntervalMinSeconds: value('contactIntervalMinSeconds'),
      contactIntervalMaxSeconds: value('contactIntervalMaxSeconds'),
      duplicateWindowHours: value('duplicateWindowHours'),
      maxPhotoUploadBytes: value('maxPhotoUploadBytes'),
    );
  }

  static InquiryPreview previewFromJson(Map<String, dynamic> json) {
    return InquiryPreview(
      greeting: json['greeting'] as String,
      question: json['question'] as String,
      messages: (json['messages'] as List<dynamic>).map((raw) {
        final message = raw as Map<String, dynamic>;
        return PreviewMessage(
          type: message['type'] == 'PHOTO'
              ? PreviewMessageType.photo
              : PreviewMessageType.text,
          text: message['text'] as String,
          photoId: message['photoId'] as String?,
        );
      }).toList(),
    );
  }

  static InquiryDraft draftFromJson(Map<String, dynamic> json) {
    return InquiryDraft(
      categoryIds: (json['categoryIds'] as List<dynamic>).cast<String>().toSet(),
      contactIds: (json['contactIds'] as List<dynamic>).cast<String>(),
      items: (json['items'] as List<dynamic>).map((raw) {
        final item = raw as Map<String, dynamic>;
        return InquiryItemDraft(
          name: item['name'] as String,
          photoId: item['photoId'] as String?,
        );
      }).toList(),
      skippedContacts: (json['skippedContacts'] as List<dynamic>? ?? const [])
          .map((raw) {
            final skipped = raw as Map<String, dynamic>;
            return SkippedContact(
              contactName: skipped['contactName'] as String,
              reason: skipped['reason'] as String,
            );
          })
          .toList(),
    );
  }

  static InquiryPhoto photoFromJson(Map<String, dynamic> json) {
    return InquiryPhoto(
      id: json['id'] as String,
      contentType: json['contentType'] as String,
      sizeBytes: (json['sizeBytes'] as num).toInt(),
      width: (json['width'] as num).toInt(),
      height: (json['height'] as num).toInt(),
    );
  }

  /// `details` do erro `DUPLICATE_INQUIRY`.
  static List<DuplicateInquiryWarning> warningsFromJson(Object? details) {
    if (details is! List) return const [];
    return details.whereType<Map<String, dynamic>>().map((json) {
      return DuplicateInquiryWarning(
        contactId: json['contactId'] as String,
        contactName: json['contactName'] as String,
        itemName: json['itemName'] as String,
        sentAt: DateTime.parse(json['sentAt'] as String),
      );
    }).toList();
  }

  static List<Map<String, dynamic>> encodeItems(List<InquiryItemDraft> items) {
    return [
      for (final item in items) {'name': item.name, 'photoId': item.photoId},
    ];
  }

  static String formatDate(DateTime date) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${date.year}-${twoDigits(date.month)}-${twoDigits(date.day)}';
  }
}
