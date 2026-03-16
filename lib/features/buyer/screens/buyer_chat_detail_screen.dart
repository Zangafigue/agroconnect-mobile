import 'package:flutter/material.dart';
import 'package:agroconnect_bf/core/config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../messaging/providers/messaging_provider.dart';
import '../../auth/providers/auth_provider.dart';

class BuyerChatDetailScreen extends ConsumerStatefulWidget {
  final String chatId;
  const BuyerChatDetailScreen({super.key, required this.chatId});

  @override
  ConsumerState<BuyerChatDetailScreen> createState() => _BuyerChatDetailScreenState();
}

class _BuyerChatDetailScreenState extends ConsumerState<BuyerChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    
    try {
      final repository = ref.read(messagingRepositoryProvider);
      await repository.sendMessage(widget.chatId, _messageController.text.trim());
      _messageController.clear();
      ref.invalidate(messagesProvider(widget.chatId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final messagesAsync = ref.watch(messagesProvider(widget.chatId));
    final authState = ref.watch(authProvider);
    final currentUserId = authState.user?.id;

    return Scaffold(
      backgroundColor: isDark ? AppConfig.bgDark : AppConfig.bgLight,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: isDark ? AppConfig.surfaceDark : Colors.white,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : AppConfig.textMainLight,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppConfig.primaryColor.withValues(alpha: 0.1),
              child: const Text('...', style: TextStyle(color: AppConfig.primaryColor, fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chargement...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('...', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(child: Text('Aucun message'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final bool isMe = msg['sender'] != null && msg['sender']['_id'] == currentUserId;
                    return _buildMessageBubble(context, msg['content'] ?? '', isMe, isDark);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Erreur: $err')),
            ),
          ),

          // Message Input
          _buildMessageInput(context, isDark),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, String text, bool isMe, bool isDark) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe 
              ? AppConfig.primaryColor 
              : (isDark ? AppConfig.surfaceDark : Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
          border: isMe ? null : Border.all(color: isDark ? AppConfig.borderDark : AppConfig.borderLight),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isMe ? Colors.white : (isDark ? AppConfig.textMainDark : AppConfig.textMainLight),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(icon: const Icon(Icons.add_circle_outline, color: AppConfig.primaryColor), onPressed: () {}),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Écrire un message...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                color: AppConfig.primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
