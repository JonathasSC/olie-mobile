import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:olie/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:olie/features/notifications/presentation/widgets/notification_list_item.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificações')),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state.status == NotificationStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == NotificationStatus.failure &&
              state.notifications.isEmpty) {
            return Center(
              child: Text(state.errorMessage ?? 'Erro ao carregar.'),
            );
          }

          if (state.notifications.isEmpty) {
            return const Center(
              child: Text('Nenhuma notificação por aqui ainda.'),
            );
          }

          return ListView.separated(
            itemCount: state.notifications.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return NotificationListItem(
                notification: state.notifications[index],
              );
            },
          );
        },
      ),
    );
  }
}
