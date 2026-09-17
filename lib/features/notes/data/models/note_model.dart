import 'package:olie/features/notes/domain/entities/note.dart';

class NoteModel extends Note {
  const NoteModel({
    required super.id,
    required super.content,
    required super.createdAt,
    required super.updatedAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {'content': content};
  }
}
