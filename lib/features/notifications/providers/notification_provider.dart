import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/notification_repository.dart';
import '../../../core/network/dio_client.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(DioClient.dio);
});

final notificationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getMyNotifications();
});
