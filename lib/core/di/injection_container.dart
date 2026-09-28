import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'package:olie/core/constants/app_constants.dart';
import 'package:olie/core/network/auth_interceptor.dart';
import 'package:olie/core/network/network_info.dart';
import 'package:olie/core/network/realtime_client.dart';
import 'package:olie/features/contacts/data/datasources/contact_remote_data_source.dart';
import 'package:olie/features/contacts/data/repositories/contact_repository_impl.dart';
import 'package:olie/features/contacts/domain/repositories/contact_repository.dart';
import 'package:olie/features/contacts/domain/usecases/add_contact.dart';
import 'package:olie/features/contacts/domain/usecases/add_contact_category.dart';
import 'package:olie/features/contacts/domain/usecases/delete_contact.dart';
import 'package:olie/features/contacts/domain/usecases/delete_contact_category.dart';
import 'package:olie/features/contacts/domain/usecases/export_contacts.dart';
import 'package:olie/features/contacts/domain/usecases/get_contact_categories.dart';
import 'package:olie/features/contacts/domain/usecases/get_contacts.dart';
import 'package:olie/features/contacts/domain/usecases/import_contacts.dart';
import 'package:olie/features/contacts/domain/usecases/rename_contact_category.dart';
import 'package:olie/features/contacts/domain/usecases/update_contact.dart';
import 'package:olie/features/contacts/presentation/bloc/contact_bloc.dart';
import 'package:olie/features/inquiries/data/datasources/inquiry_realtime_data_source.dart';
import 'package:olie/features/inquiries/data/datasources/inquiry_remote_data_source.dart';
import 'package:olie/features/inquiries/data/repositories/inquiry_repository_impl.dart';
import 'package:olie/features/inquiries/domain/repositories/inquiry_repository.dart';
import 'package:olie/features/inquiries/domain/usecases/cancel_inquiry.dart';
import 'package:olie/features/inquiries/domain/usecases/create_inquiry.dart';
import 'package:olie/features/inquiries/domain/usecases/get_inquiries.dart';
import 'package:olie/features/inquiries/domain/usecases/get_inquiry.dart';
import 'package:olie/features/inquiries/domain/usecases/get_inquiry_draft.dart';
import 'package:olie/features/inquiries/domain/usecases/get_inquiry_photo.dart';
import 'package:olie/features/inquiries/domain/usecases/get_inquiry_settings.dart';
import 'package:olie/features/inquiries/domain/usecases/pause_inquiry.dart';
import 'package:olie/features/inquiries/domain/usecases/preview_inquiry.dart';
import 'package:olie/features/inquiries/domain/usecases/resend_failed_inquiry.dart';
import 'package:olie/features/inquiries/domain/usecases/resume_inquiry.dart';
import 'package:olie/features/inquiries/domain/usecases/upload_inquiry_photo.dart';
import 'package:olie/features/inquiries/domain/usecases/watch_inquiry_events.dart';
import 'package:olie/features/inquiries/presentation/bloc/inquiry_bloc.dart';
import 'package:olie/features/inquiries/presentation/bloc/inquiry_composer_bloc.dart';
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
import 'package:olie/features/wear_items/data/datasources/wear_item_remote_data_source.dart';
import 'package:olie/features/wear_items/data/repositories/wear_item_repository_impl.dart';
import 'package:olie/features/wear_items/domain/repositories/wear_item_repository.dart';
import 'package:olie/features/wear_items/domain/usecases/add_wear_item.dart';
import 'package:olie/features/wear_items/domain/usecases/delete_wear_item.dart';
import 'package:olie/features/wear_items/domain/usecases/get_wear_item_detail.dart';
import 'package:olie/features/wear_items/domain/usecases/get_wear_items.dart';
import 'package:olie/features/wear_items/domain/usecases/replace_wear_item.dart';
import 'package:olie/features/wear_items/domain/usecases/update_wear_item.dart';
import 'package:olie/features/wear_items/presentation/bloc/wear_item_bloc.dart';
import 'package:olie/features/whatsapp/data/datasources/whatsapp_realtime_data_source.dart';
import 'package:olie/features/whatsapp/data/datasources/whatsapp_remote_data_source.dart';
import 'package:olie/features/whatsapp/data/repositories/whatsapp_repository_impl.dart';
import 'package:olie/features/whatsapp/domain/repositories/whatsapp_repository.dart';
import 'package:olie/features/whatsapp/domain/usecases/connect_whatsapp.dart';
import 'package:olie/features/whatsapp/domain/usecases/disconnect_whatsapp.dart';
import 'package:olie/features/whatsapp/domain/usecases/get_whatsapp_connection.dart';
import 'package:olie/features/whatsapp/domain/usecases/watch_whatsapp_connection.dart';
import 'package:olie/features/whatsapp/presentation/bloc/whatsapp_bloc.dart';

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
  // Uma conexão STOMP para toda a sessão (notificações, WhatsApp, consultas).
  sl.registerLazySingleton<RealtimeClient>(() => RealtimeClient(sl()));

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

  // Feature: Wear Items
  sl.registerLazySingleton<WearItemRemoteDataSource>(
    () => WearItemRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<WearItemRepository>(
    () => WearItemRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton(() => GetWearItems(sl()));
  sl.registerLazySingleton(() => GetWearItemDetail(sl()));
  sl.registerLazySingleton(() => AddWearItem(sl()));
  sl.registerLazySingleton(() => UpdateWearItem(sl()));
  sl.registerLazySingleton(() => DeleteWearItem(sl()));
  sl.registerLazySingleton(() => ReplaceWearItem(sl()));

  sl.registerFactory(
    () => WearItemBloc(
      getWearItems: sl(),
      getWearItemDetail: sl(),
      addWearItem: sl(),
      updateWearItem: sl(),
      deleteWearItem: sl(),
      replaceWearItem: sl(),
    ),
  );

  // Feature: Contacts
  sl.registerLazySingleton<ContactRemoteDataSource>(
    () => ContactRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<ContactRepository>(
    () => ContactRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton(() => GetContacts(sl()));
  sl.registerLazySingleton(() => GetContactCategories(sl()));
  sl.registerLazySingleton(() => AddContact(sl()));
  sl.registerLazySingleton(() => UpdateContact(sl()));
  sl.registerLazySingleton(() => DeleteContact(sl()));
  sl.registerLazySingleton(() => AddContactCategory(sl()));
  sl.registerLazySingleton(() => RenameContactCategory(sl()));
  sl.registerLazySingleton(() => DeleteContactCategory(sl()));
  sl.registerLazySingleton(() => ImportContacts(sl()));
  sl.registerLazySingleton(() => ExportContacts(sl()));

  sl.registerFactory(
    () => ContactBloc(
      getContacts: sl(),
      getContactCategories: sl(),
      addContact: sl(),
      updateContact: sl(),
      deleteContact: sl(),
      addContactCategory: sl(),
      renameContactCategory: sl(),
      deleteContactCategory: sl(),
      importContacts: sl(),
      exportContacts: sl(),
    ),
  );

  // Feature: WhatsApp
  sl.registerLazySingleton<WhatsAppRemoteDataSource>(
    () => WhatsAppRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<WhatsAppRealtimeDataSource>(
    () => WhatsAppRealtimeDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<WhatsAppRepository>(
    () => WhatsAppRepositoryImpl(
      remoteDataSource: sl(),
      realtimeDataSource: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetWhatsAppConnection(sl()));
  sl.registerLazySingleton(() => ConnectWhatsApp(sl()));
  sl.registerLazySingleton(() => DisconnectWhatsApp(sl()));
  sl.registerLazySingleton(() => WatchWhatsAppConnection(sl()));

  sl.registerFactory(
    () => WhatsAppBloc(
      getWhatsAppConnection: sl(),
      connectWhatsApp: sl(),
      disconnectWhatsApp: sl(),
      watchWhatsAppConnection: sl(),
    ),
  );

  // Feature: Inquiries
  sl.registerLazySingleton<InquiryRemoteDataSource>(
    () => InquiryRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<InquiryRealtimeDataSource>(
    () => InquiryRealtimeDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<InquiryRepository>(
    () => InquiryRepositoryImpl(
      remoteDataSource: sl(),
      realtimeDataSource: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetInquirySettings(sl()));
  sl.registerLazySingleton(() => PreviewInquiry(sl()));
  sl.registerLazySingleton(() => CreateInquiry(sl()));
  sl.registerLazySingleton(() => GetInquiries(sl()));
  sl.registerLazySingleton(() => GetInquiry(sl()));
  sl.registerLazySingleton(() => GetInquiryDraft(sl()));
  sl.registerLazySingleton(() => PauseInquiry(sl()));
  sl.registerLazySingleton(() => ResumeInquiry(sl()));
  sl.registerLazySingleton(() => CancelInquiry(sl()));
  sl.registerLazySingleton(() => ResendFailedInquiry(sl()));
  sl.registerLazySingleton(() => UploadInquiryPhoto(sl()));
  sl.registerLazySingleton(() => GetInquiryPhoto(sl()));
  sl.registerLazySingleton(() => WatchInquiryEvents(sl()));

  sl.registerFactory(
    () => InquiryBloc(
      getInquiries: sl(),
      getInquiry: sl(),
      pauseInquiry: sl(),
      resumeInquiry: sl(),
      cancelInquiry: sl(),
      resendFailedInquiry: sl(),
      watchInquiryEvents: sl(),
    ),
  );

  sl.registerFactory(
    () => InquiryComposerBloc(
      getInquirySettings: sl(),
      getInquiryDraft: sl(),
      uploadInquiryPhoto: sl(),
      previewInquiry: sl(),
      createInquiry: sl(),
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
