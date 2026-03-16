import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agroconnect_bf/core/config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../messaging/providers/messaging_provider.dart';

class BuyerChatListScreen extends ConsumerWidget {
  const BuyerChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final conversationsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppConfig.bgDark : AppConfig.bgLight,
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "AgroConnect BF",
                  style: TextStyle(
                    color: isDark ? Colors.white : AppConfig.textMainLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            Text(
              "Messages",
              style: TextStyle(
                color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: 8),
        ],
        foregroundColor: isDark ? Colors.white : AppConfig.textMainLight,
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
                  hintText: 'Rechercher une conversation...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ),
            ),
          ),

          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('Tous', true, isDark),
                const SizedBox(width: 8),
                _buildFilterChip('Achats', false, isDark),
                const SizedBox(width: 8),
                _buildFilterChip('Logistique', false, isDark),
              ],
            ),
          ),

          const SizedBox(height: 16),

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
                        Text(
                          "Aucune conversation pour le moment",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
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
                      (p) => p is Map && p['_id'] != null, // simplified participant logic
                      orElse: () => {'firstName': 'Utilisateur', 'lastName': ''}
                    );
                    
                    return _buildChatTile(
                      context,
                      name: "${otherParticipant['firstName']} ${otherParticipant['lastName']}",
                      lastMsg: chat['lastMessage']?['content'] ?? 'Nouvelle conversation',
                      time: 'À l\'instant', // simplified time
                      unread: 0,
                      isOnline: false,
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

  Widget _buildFilterChip(String label, bool isActive, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppConfig.primaryColor : (isDark ? AppConfig.surfaceDark : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isActive ? AppConfig.primaryColor : (isDark ? AppConfig.borderDark : AppConfig.borderLight)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : (isDark ? AppConfig.textSubDark : AppConfig.textSubLight),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildChatTile(
    BuildContext context, {
    required String name,
    required String lastMsg,
    required String time,
    required int unread,
    required bool isOnline,
    required bool isDark,
    required String chatId,
  }) {
    return ListTile(
      onTap: () => context.push('/buyer/messages/$chatId'),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppConfig.primaryColor.withValues(alpha: 0.1),
            child: Text(name[0], style: const TextStyle(color: AppConfig.primaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          if (isOnline)
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: isDark ? AppConfig.bgDark : Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(time, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              lastMsg,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: unread > 0 ? (isDark ? Colors.white : AppConfig.textMainLight) : Colors.grey,
                fontWeight: unread > 0 ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
          if (unread > 0)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppConfig.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                unread.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
