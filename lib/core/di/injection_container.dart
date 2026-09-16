import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'package:olie/core/constants/app_constants.dart';
import 'package:olie/core/network/network_info.dart';
import 'package:olie/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:olie/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:olie/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:olie/features/auth/domain/repositories/auth_repository.dart';
import 'package:olie/features/auth/domain/usecases/login.dart';
import 'package:olie/features/auth/domain/usecases/register.dart';
import 'package:olie/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:olie/features/todo/data/datasources/todo_local_data_source.dart';
import 'package:olie/features/todo/data/repositories/todo_repository_impl.dart';
import 'package:olie/features/todo/domain/repositories/todo_repository.dart';
import 'package:olie/features/todo/domain/usecases/add_todo.dart';
import 'package:olie/features/todo/domain/usecases/delete_todo.dart';
import 'package:olie/features/todo/domain/usecases/get_todos.dart';
import 'package:olie/features/todo/domain/usecases/toggle_todo.dart';
import 'package:olie/features/todo/presentation/bloc/todo_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Core
  sl.registerLazySingleton<Dio>(
    () => Dio(BaseOptions(baseUrl: AppConstants.baseUrl)),
  );
  sl.registerLazySingleton<InternetConnection>(() => InternetConnection());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // Feature: Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => Register(sl()));

  sl.registerFactory(() => AuthBloc(login: sl(), register: sl()));

  // Feature: Todo
  sl.registerLazySingleton<TodoLocalDataSource>(
    () => TodoLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<TodoRepository>(
    () => TodoRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton(() => GetTodos(sl()));
  sl.registerLazySingleton(() => AddTodo(sl()));
  sl.registerLazySingleton(() => ToggleTodo(sl()));
  sl.registerLazySingleton(() => DeleteTodo(sl()));

  sl.registerFactory(
    () => TodoBloc(
      getTodos: sl(),
      addTodo: sl(),
      toggleTodo: sl(),
      deleteTodo: sl(),
    ),
  );
}
