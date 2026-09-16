import 'package:olie/core/error/exceptions.dart';
import 'package:olie/features/todo/data/models/todo_model.dart';

abstract class TodoLocalDataSource {
  Future<List<TodoModel>> getTodos();

  Future<TodoModel> addTodo(String title);

  Future<TodoModel> toggleTodo(String id);

  Future<void> deleteTodo(String id);
}

/// In-memory implementation used as the initial storage for this template.
/// Swap this for a `shared_preferences`, `sqflite` or `hive` backed
/// implementation once persistence is needed, without touching the
/// domain or presentation layers.
class TodoLocalDataSourceImpl implements TodoLocalDataSource {
  final List<TodoModel> _storage = [];

  @override
  Future<List<TodoModel>> getTodos() async {
    return List.unmodifiable(_storage);
  }

  @override
  Future<TodoModel> addTodo(String title) async {
    if (title.trim().isEmpty) {
      throw const CacheException('O título não pode ser vazio.');
    }

    final todo = TodoModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim(),
    );
    _storage.add(todo);
    return todo;
  }

  @override
  Future<TodoModel> toggleTodo(String id) async {
    final index = _storage.indexWhere((todo) => todo.id == id);
    if (index == -1) {
      throw const CacheException('Tarefa não encontrada.');
    }

    final updated = _storage[index].copyWith(isDone: !_storage[index].isDone);
    _storage[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteTodo(String id) async {
    final removed = _storage.any((todo) => todo.id == id);
    if (!removed) {
      throw const CacheException('Tarefa não encontrada.');
    }
    _storage.removeWhere((todo) => todo.id == id);
  }
}
