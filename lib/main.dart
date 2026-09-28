import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:olie/core/constants/app_constants.dart';
import 'package:olie/core/di/injection_container.dart' as di;
import 'package:olie/core/theme/app_theme.dart';
import 'package:olie/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:olie/features/auth/presentation/screens/login_screen.dart';
import 'package:olie/features/auth/presentation/screens/register_screen.dart';
import 'package:olie/features/home/presentation/screens/home_shell.dart';
import 'package:olie/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:olie/features/notifications/presentation/screens/notifications_screen.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.initDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider.value(value: di.sl<NotificationBloc>()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: scaffoldMessengerKey,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        initialRoute: '/login',
        builder: (context, child) {
          return BlocListener<NotificationBloc, NotificationState>(
            listenWhen: (previous, current) =>
                current.lastReceived != null &&
                previous.lastReceived != current.lastReceived,
            listener: (context, state) {
              scaffoldMessengerKey.currentState
                ?..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text(state.lastReceived!.message)),
                );
            },
            child: child,
          );
        },
        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => const HomeShell(),
          '/notifications': (_) => const NotificationsScreen(),
        },
      ),
    );
  }
}
