import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'package:olie/core/network/api_error_mapper.dart';
import 'package:olie/features/contacts/data/models/contact_category_model.dart';
import 'package:olie/features/contacts/data/models/contact_import_model.dart';
import 'package:olie/features/contacts/data/models/contact_model.dart';
import 'package:olie/features/contacts/domain/entities/contact_file.dart';
import 'package:olie/features/contacts/domain/entities/contact_import.dart';

abstract class ContactRemoteDataSource {
  Future<List<ContactModel>> getContacts();

  Future<List<ContactCategoryModel>> getContactCategories();

  Future<ContactModel> addContact(Map<String, dynamic> body);

  Future<ContactModel> updateContact(String id, Map<String, dynamic> body);

  Future<void> deleteContact(String id);

  Future<ContactCategoryModel> addContactCategory(String name);

  Future<ContactCategoryModel> renameContactCategory(String id, String name);

  Future<void> deleteContactCategory(String id, {required bool unlinkContacts});

  Future<ContactImportResult> importContacts(Uint8List bytes, String fileName);

  Future<ContactFile> exportContacts(ContactFileFormat format);
}

class ContactRemoteDataSourceImpl implements ContactRemoteDataSource {
  final Dio dio;

  ContactRemoteDataSourceImpl(this.dio);

  @override
  Future<List<ContactModel>> getContacts() async {
    try {
      final response = await dio.get<List<dynamic>>('/contacts');
      return response.data!
          .map((json) => ContactModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw mapDioException(e, fallback: 'Não foi possível carregar os contatos.');
    }
  }

  @override
  Future<List<ContactCategoryModel>> getContactCategories() async {
    try {
      final response = await dio.get<List<dynamic>>('/contact-categories');
      return response.data!
          .map(
            (json) =>
                ContactCategoryModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      throw mapDioException(
        e,
        fallback: 'Não foi possível carregar as categorias.',
      );
    }
  }

  @override
  Future<ContactModel> addContact(Map<String, dynamic> body) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/contacts',
        data: body,
      );
      return ContactModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioException(e, fallback: 'Não foi possível salvar o contato.');
    }
  }

  @override
  Future<ContactModel> updateContact(
    String id,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await dio.put<Map<String, dynamic>>(
        '/contacts/$id',
        data: body,
      );
      return ContactModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioException(e, fallback: 'Não foi possível salvar o contato.');
    }
  }

  @override
  Future<void> deleteContact(String id) async {
    try {
      await dio.delete<void>('/contacts/$id');
    } on DioException catch (e) {
      throw mapDioException(e, fallback: 'Não foi possível remover o contato.');
    }
  }

  @override
  Future<ContactCategoryModel> addContactCategory(String name) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/contact-categories',
        data: {'name': name},
      );
      return ContactCategoryModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioException(e, fallback: 'Não foi possível criar a categoria.');
    }
  }

  @override
  Future<ContactCategoryModel> renameContactCategory(
    String id,
    String name,
  ) async {
    try {
      final response = await dio.put<Map<String, dynamic>>(
        '/contact-categories/$id',
        data: {'name': name},
      );
      return ContactCategoryModel.fromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioException(
        e,
        fallback: 'Não foi possível renomear a categoria.',
      );
    }
  }

  @override
  Future<void> deleteContactCategory(
    String id, {
    required bool unlinkContacts,
  }) async {
    try {
      await dio.delete<void>(
        '/contact-categories/$id',
        queryParameters: {'unlinkContacts': unlinkContacts},
      );
    } on DioException catch (e) {
      throw mapDioException(
        e,
        fallback: 'Não foi possível remover a categoria.',
      );
    }
  }

  @override
  Future<ContactImportResult> importContacts(
    Uint8List bytes,
    String fileName,
  ) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/contacts/import',
        data: FormData.fromMap({
          'file': MultipartFile.fromBytes(bytes, filename: fileName),
        }),
      );
      return ContactImportModel.resultFromJson(response.data!);
    } on DioException catch (e) {
      throw mapDioException(e, fallback: 'Não foi possível importar o arquivo.');
    }
  }

  @override
  Future<ContactFile> exportContacts(ContactFileFormat format) async {
    try {
      final response = await dio.get<List<int>>(
        '/contacts/export',
        queryParameters: {'format': format.apiValue},
        options: Options(responseType: ResponseType.bytes),
      );
      return ContactFile(
        fileName: 'contatos.${format.extension}',
        bytes: Uint8List.fromList(response.data!),
      );
    } on DioException catch (e) {
      throw mapDioException(e, fallback: 'Não foi possível exportar os contatos.');
    }
  }
}
