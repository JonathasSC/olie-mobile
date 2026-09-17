import 'package:dio/dio.dart';

import 'package:olie/core/error/exceptions.dart';
import 'package:olie/features/notes/data/models/note_model.dart';

abstract class NoteRemoteDataSource {
  Future<List<NoteModel>> getNotes();

  Future<NoteModel> addNote(String content);

  Future<NoteModel> updateNote({required String id, required String content});

  Future<void> deleteNote(String id);
}

class NoteRemoteDataSourceImpl implements NoteRemoteDataSource {
  final Dio dio;

  NoteRemoteDataSourceImpl(this.dio);

  @override
  Future<List<NoteModel>> getNotes() async {
    try {
      final response = await dio.get<List<dynamic>>('/notes');
      return response.data!
          .map((json) => NoteModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _mapDioException(e, fallback: 'Não foi possível carregar as notas.');
    }
  }

  @override
  Future<NoteModel> addNote(String content) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/notes',
        data: {'content': content},
      );
      return NoteModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioException(e, fallback: 'Não foi possível criar a nota.');
    }
  }

  @override
  Future<NoteModel> updateNote({
    required String id,
    required String content,
  }) async {
    try {
      final response = await dio.put<Map<String, dynamic>>(
        '/notes/$id',
        data: {'content': content},
      );
      return NoteModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw _mapDioException(e, fallback: 'Não foi possível atualizar a nota.');
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    try {
      await dio.delete<void>('/notes/$id');
    } on DioException catch (e) {
      throw _mapDioException(e, fallback: 'Não foi possível remover a nota.');
    }
  }

  Exception _mapDioException(DioException e, {required String fallback}) {
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const NetworkException();
      default:
        final data = e.response?.data;
        final message = data is Map<String, dynamic>
            ? data['message'] as String?
            : null;
        return ServerException(message ?? fallback);
    }
  }
}
