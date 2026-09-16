import 'package:olie/features/todo/domain/entities/todo.dart';

class TodoModel extends Todo {
  const TodoModel({
    required super.id,
    required super.title,
    super.isDone = false,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'] as String,
      title: json['title'] as String,
      isDone: json['isDone'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone,
    };
  }

  factory TodoModel.fromEntity(Todo todo) {
    return TodoModel(id: todo.id, title: todo.title, isDone: todo.isDone);
  }

  @override
  TodoModel copyWith({String? id, String? title, bool? isDone}) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }
}
