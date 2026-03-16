import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agroconnect_bf/core/config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../messaging/providers/messaging_provider.dart';
import '../../auth/providers/auth_provider.dart';

class TransporterChatListScreen extends ConsumerWidget {
  const TransporterChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final conversationsAsync = ref.watch(conversationsProvider);
    final authState = ref.watch(authProvider);
    final currentUserId = authState.user?.id;

    return Scaffold(
      backgroundColor: isDark ? AppConfig.bgDark : AppConfig.bgLight,
      appBar: AppBar(
        title: const Text("Messages Logistique"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                decoration: InputDecoration(
                  icon: const Icon(Icons.search, color: Colors.grey),
                  hintText: 'Rechercher un transport...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ),
            ),
          ),

          Expanded(
            child: conversationsAsync.when(
              data: (conversations) {
                if (conversations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text("Aucune conversation logistique"),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: conversations.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  separatorBuilder: (context, index) => Divider(
                    height: 1, 
                    indent: 70, 
                    color: isDark ? AppConfig.borderDark : AppConfig.borderLight,
                  ),
                  itemBuilder: (context, index) {
                    final chat = conversations[index];
                    final List participants = chat['participants'] ?? [];
                    final otherParticipant = participants.firstWhere(
                      (p) => p is Map && p['_id'] != currentUserId,
                      orElse: () => {'firstName': 'Utilisateur'}
                    );
                    
                    return _buildChatTile(
                      context,
                      name: otherParticipant['firstName'] ?? 'Utilisateur',
                      lastMsg: chat['lastMessage']?['content'] ?? 'Nouvel échange',
                      time: 'Logistique',
                      unread: 0,
                      isDark: isDark,
                      chatId: chat['_id'] ?? '',
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Erreur: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTile(
    BuildContext context, {
    required String name,
    required String lastMsg,
    required String time,
    required int unread,
    required bool isDark,
    required String chatId,
  }) {
    return ListTile(
      onTap: () => context.push('/transporter/messages/$chatId'),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: AppConfig.primaryColor.withValues(alpha: 0.1),
        child: Text(name.isNotEmpty ? name[0] : '?', style: const TextStyle(color: AppConfig.primaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(time, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ],
      ),
      subtitle: Text(
        lastMsg,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: unread > 0 ? (isDark ? Colors.white : AppConfig.textMainLight) : Colors.grey,
          fontWeight: unread > 0 ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }
}
