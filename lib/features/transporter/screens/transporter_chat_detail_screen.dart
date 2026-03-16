import 'package:flutter/material.dart';
import 'package:agroconnect_bf/core/config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../messaging/providers/messaging_provider.dart';
import '../../auth/providers/auth_provider.dart';

class TransporterChatDetailScreen extends ConsumerStatefulWidget {
  final String chatId;
  const TransporterChatDetailScreen({
    super.key,
    required this.chatId,
  });

  @override
  ConsumerState<TransporterChatDetailScreen> createState() => _TransporterChatDetailScreenState();
}

class _TransporterChatDetailScreenState extends ConsumerState<TransporterChatDetailScreen> {
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
        title: const Text('Logistique Détail'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: AppConfig.primaryColor),
            onPressed: () {},
          ),
        ],
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
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final dynamic sender = msg['sender'];
                    final String? senderId = sender is Map ? sender['_id'] : sender?.toString();
                    final bool isMe = senderId == currentUserId;
                    final isOffer = msg['type'] == 'PRICE_OFFER';

                    if (isOffer) {
                      return _buildOfferBubble(msg, isMe, isDark);
                    }
                    return _buildMessage(msg['content'] ?? '', 'À l\'instant', isMe, isDark);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Erreur: $err')),
            ),
          ),
          // Input Area
          _buildMessageInput(context, isDark),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.bgDark : Colors.white,
        border: Border(top: BorderSide(color: AppConfig.primaryColor.withValues(alpha: 0.1))),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file, color: Colors.grey),
              onPressed: () {},
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppConfig.primaryColor.withValues(alpha: 0.05) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppConfig.primaryColor.withValues(alpha: 0.1)),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Écrire un message...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(color: AppConfig.primaryColor, shape: BoxShape.circle),
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

  Widget _buildMessage(String text, String time, bool isMe, bool isDark) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: const BoxConstraints(maxWidth: 280),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? AppConfig.primaryColor : (isDark ? AppConfig.primaryColor.withValues(alpha: 0.15) : Colors.grey[200]),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 0),
                  bottomRight: Radius.circular(isMe ? 0 : 20),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferBubble(Map<String, dynamic> msg, bool isMe, bool isDark) {
    final Map<String, dynamic> offer = msg['offer'] ?? {};
    final status = offer['status'] ?? 'PENDING';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        width: 280,
        decoration: BoxDecoration(
          color: isDark ? AppConfig.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppConfig.warning.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(color: AppConfig.warning.withValues(alpha: isDark ? 0.05 : 0.1), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppConfig.warning.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.local_offer_outlined, color: AppConfig.warning, size: 18),
                  SizedBox(width: 8),
                  Text('OFFRE DE PRIX', style: TextStyle(fontWeight: FontWeight.bold, color: AppConfig.warning, fontSize: 10)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    msg['content'] ?? 'Offre de prix',
                    style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${offer['amount']} FCFA',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConfig.warning),
                  ),
                  const SizedBox(height: 12),
                  if (status == 'PENDING' && !isMe)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _respondToOffer(msg['_id'], 'REJECT'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppConfig.error,
                              side: const BorderSide(color: AppConfig.error),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text('Refuser', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _respondToOffer(msg['_id'], 'ACCEPT'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConfig.primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text('Accepter', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      status == 'ACCEPTED' ? '✅ ACCEPTÉE' : (status == 'REJECTED' ? '❌ REFUSÉE' : '⏳ EN ATTENTE'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: status == 'ACCEPTED' ? AppConfig.success : (status == 'REJECTED' ? AppConfig.error : Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _respondToOffer(String msgId, String action) async {
    try {
      await ref.read(messagingRepositoryProvider).respondToOffer(msgId, action);
      ref.invalidate(messagesProvider(widget.chatId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }
}
