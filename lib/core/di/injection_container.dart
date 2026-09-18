import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'package:olie/core/constants/app_constants.dart';
import 'package:olie/core/network/auth_interceptor.dart';
import 'package:olie/core/network/network_info.dart';
import 'package:olie/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:olie/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:olie/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:olie/features/auth/domain/repositories/auth_repository.dart';
import 'package:olie/features/auth/domain/usecases/login.dart';
import 'package:olie/features/auth/domain/usecases/register.dart';
import 'package:olie/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:olie/features/notes/data/datasources/note_remote_data_source.dart';
import 'package:olie/features/notes/data/repositories/note_repository_impl.dart';
import 'package:olie/features/notes/domain/repositories/note_repository.dart';
import 'package:olie/features/notes/domain/usecases/add_note.dart';
import 'package:olie/features/notes/domain/usecases/delete_note.dart';
import 'package:olie/features/notes/domain/usecases/get_notes.dart';
import 'package:olie/features/notes/domain/usecases/update_note.dart';
import 'package:olie/features/notes/presentation/bloc/note_bloc.dart';
import 'package:olie/features/notifications/data/datasources/notification_realtime_data_source.dart';
import 'package:olie/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:olie/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:olie/features/notifications/domain/repositories/notification_repository.dart';
import 'package:olie/features/notifications/domain/usecases/disconnect_realtime_notifications.dart';
import 'package:olie/features/notifications/domain/usecases/get_notifications.dart';
import 'package:olie/features/notifications/domain/usecases/watch_realtime_notifications.dart';
import 'package:olie/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:olie/features/planned_items/data/datasources/planned_item_remote_data_source.dart';
import 'package:olie/features/planned_items/data/repositories/planned_item_repository_impl.dart';
import 'package:olie/features/planned_items/domain/repositories/planned_item_repository.dart';
import 'package:olie/features/planned_items/domain/usecases/add_planned_item.dart';
import 'package:olie/features/planned_items/domain/usecases/complete_planned_item.dart';
import 'package:olie/features/planned_items/domain/usecases/delete_planned_item.dart';
import 'package:olie/features/planned_items/domain/usecases/get_planned_items.dart';
import 'package:olie/features/planned_items/domain/usecases/update_planned_item.dart';
import 'package:olie/features/planned_items/presentation/bloc/planned_item_bloc.dart';
import 'package:olie/features/savings_goals/data/datasources/savings_goal_remote_data_source.dart';
import 'package:olie/features/savings_goals/data/repositories/savings_goal_repository_impl.dart';
import 'package:olie/features/savings_goals/domain/repositories/savings_goal_repository.dart';
import 'package:olie/features/savings_goals/domain/usecases/add_savings_goal.dart';
import 'package:olie/features/savings_goals/domain/usecases/delete_savings_goal.dart';
import 'package:olie/features/savings_goals/domain/usecases/get_savings_goals.dart';
import 'package:olie/features/savings_goals/domain/usecases/update_savings_goal.dart';
import 'package:olie/features/savings_goals/presentation/bloc/savings_goal_bloc.dart';
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
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<Dio>(
    () => Dio(BaseOptions(baseUrl: AppConstants.baseUrl))
      ..interceptors.add(AuthInterceptor(sl())),
  );
  sl.registerLazySingleton<InternetConnection>(() => InternetConnection());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // Feature: Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
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

  // Feature: Notes
  sl.registerLazySingleton<NoteRemoteDataSource>(
    () => NoteRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<NoteRepository>(
    () => NoteRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton(() => GetNotes(sl()));
  sl.registerLazySingleton(() => AddNote(sl()));
  sl.registerLazySingleton(() => UpdateNote(sl()));
  sl.registerLazySingleton(() => DeleteNote(sl()));

  sl.registerFactory(
    () => NoteBloc(
      getNotes: sl(),
      addNote: sl(),
      updateNote: sl(),
      deleteNote: sl(),
    ),
  );

  // Feature: Planned Items
  sl.registerLazySingleton<PlannedItemRemoteDataSource>(
    () => PlannedItemRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<PlannedItemRepository>(
    () => PlannedItemRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton(() => GetPlannedItems(sl()));
  sl.registerLazySingleton(() => AddPlannedItem(sl()));
  sl.registerLazySingleton(() => UpdatePlannedItem(sl()));
  sl.registerLazySingleton(() => DeletePlannedItem(sl()));
  sl.registerLazySingleton(() => CompletePlannedItem(sl()));

  sl.registerFactory(
    () => PlannedItemBloc(
      getPlannedItems: sl(),
      addPlannedItem: sl(),
      updatePlannedItem: sl(),
      deletePlannedItem: sl(),
      completePlannedItem: sl(),
    ),
  );

  // Feature: Savings Goals
  sl.registerLazySingleton<SavingsGoalRemoteDataSource>(
    () => SavingsGoalRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<SavingsGoalRepository>(
    () => SavingsGoalRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton(() => GetSavingsGoals(sl()));
  sl.registerLazySingleton(() => AddSavingsGoal(sl()));
  sl.registerLazySingleton(() => UpdateSavingsGoal(sl()));
  sl.registerLazySingleton(() => DeleteSavingsGoal(sl()));

  sl.registerFactory(
    () => SavingsGoalBloc(
      getSavingsGoals: sl(),
      addSavingsGoal: sl(),
      updateSavingsGoal: sl(),
      deleteSavingsGoal: sl(),
    ),
  );

  // Feature: Notifications
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<NotificationRealtimeDataSource>(
    () => NotificationRealtimeDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDataSource: sl(),
      realtimeDataSource: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetNotifications(sl()));
  sl.registerLazySingleton(() => WatchRealtimeNotifications(sl()));
  sl.registerLazySingleton(() => DisconnectRealtimeNotifications(sl()));

  // Singleton (não factory): precisa sobreviver à navegação entre telas
  // para manter a conexão WebSocket viva durante toda a sessão do usuário.
  sl.registerLazySingleton(
    () => NotificationBloc(
      getNotifications: sl(),
      watchRealtimeNotifications: sl(),
      disconnectRealtimeNotifications: sl(),
    ),
  );
}
