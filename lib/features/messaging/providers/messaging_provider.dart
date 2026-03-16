import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/messaging_repository.dart';
import '../../../core/network/dio_client.dart';

final messagingRepositoryProvider = Provider<MessagingRepository>((ref) {
  return MessagingRepository(DioClient.dio);
});

final conversationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(messagingRepositoryProvider);
  return repository.getConversations();
});

final messagesProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, conversationId) async {
  final repository = ref.watch(messagingRepositoryProvider);
  return repository.getMessages(conversationId);
});
