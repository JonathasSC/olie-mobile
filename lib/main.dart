import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:olie/core/constants/app_constants.dart';
import 'package:olie/core/di/injection_container.dart' as di;
import 'package:olie/core/theme/app_theme.dart';
import 'package:olie/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:olie/features/auth/presentation/screens/login_screen.dart';
import 'package:olie/features/auth/presentation/screens/register_screen.dart';
import 'package:olie/features/notes/presentation/bloc/note_bloc.dart';
import 'package:olie/features/notes/presentation/screens/notes_screen.dart';
import 'package:olie/features/planned_items/presentation/bloc/planned_item_bloc.dart';
import 'package:olie/features/planned_items/presentation/screens/planned_items_screen.dart';
import 'package:olie/features/savings_goals/presentation/bloc/savings_goal_bloc.dart';
import 'package:olie/features/savings_goals/presentation/screens/savings_goals_screen.dart';
import 'package:olie/features/todo/presentation/bloc/todo_bloc.dart';
import 'package:olie/features/todo/presentation/screens/todo_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.initDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<AuthBloc>(),
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        initialRoute: '/login',
        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => BlocProvider(
                create: (_) => di.sl<TodoBloc>()..add(const TodosRequested()),
                child: const TodoScreen(),
              ),
          '/notes': (_) => BlocProvider(
                create: (_) => di.sl<NoteBloc>()..add(const NotesRequested()),
                child: const NotesScreen(),
              ),
          '/planned-items': (_) => BlocProvider(
                create: (_) => di.sl<PlannedItemBloc>()
                  ..add(const PlannedItemsRequested()),
                child: const PlannedItemsScreen(),
              ),
          '/savings-goals': (_) => BlocProvider(
                create: (_) => di.sl<SavingsGoalBloc>()
                  ..add(const SavingsGoalsRequested()),
                child: const SavingsGoalsScreen(),
              ),
        },
      ),
    );
  }
}
