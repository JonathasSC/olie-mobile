import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:olie/core/usecases/usecase.dart';
import 'package:olie/features/notifications/domain/entities/app_notification.dart';
import 'package:olie/features/notifications/domain/entities/app_notification_type.dart';
import 'package:olie/features/notifications/domain/repositories/notification_repository.dart';
import 'package:olie/features/notifications/domain/usecases/get_notifications.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  late MockNotificationRepository repository;
  late GetNotifications usecase;

  setUp(() {
    repository = MockNotificationRepository();
    usecase = GetNotifications(repository);
  });

  final notifications = [
    AppNotification(
      id: 'uuid',
      type: AppNotificationType.purchaseDateApproaching,
      message: 'A data estimada da compra está se aproximando.',
      plannedItemId: 'planned-uuid',
      receivedAt: DateTime.utc(2026, 11, 28, 12),
    ),
  ];

  test(
    'deve retornar a lista de notificações quando o repositório é bem-sucedido',
    () async {
      when(
        () => repository.getNotifications(),
      ).thenAnswer((_) async => Right(notifications));

      final result = await usecase(const NoParams());

      expect(result, Right(notifications));
      verify(() => repository.getNotifications()).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}
