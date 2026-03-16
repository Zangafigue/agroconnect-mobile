import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config.dart';
import '../../auth/providers/auth_provider.dart';
import '../../messaging/providers/messaging_provider.dart';

class NegotiationChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  const NegotiationChatScreen({super.key, required this.chatId});

  @override
  ConsumerState<NegotiationChatScreen> createState() => _NegotiationChatScreenState();
}

class _NegotiationChatScreenState extends ConsumerState<NegotiationChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;
    try {
      await ref.read(messagingRepositoryProvider).sendMessage(widget.chatId, _messageController.text);
      _messageController.clear();
      ref.invalidate(messagesProvider(widget.chatId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final messagesAsync = ref.watch(messagesProvider(widget.chatId));
    final authState = ref.watch(authProvider);
    final currentUserId = authState.user?.id;

    return Scaffold(
      backgroundColor: isDark ? AppConfig.bgDark : AppConfig.bgLight,
      appBar: AppBar(
        title: const Text('Négociation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? AppConfig.surfaceDark : Colors.white,
        elevation: 1,
        foregroundColor: isDark ? Colors.white : AppConfig.textMainLight,
      ),
      body: messagesAsync.when(
        data: (messages) => Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isMe = msg['sender'] == currentUserId || (msg['sender'] is Map && msg['sender']['_id'] == currentUserId);
                  final isOffer = msg['type'] == 'PRICE_OFFER';
                  
                  if (isOffer) {
                    return _buildOfferBubble(msg, isMe, isDark);
                  }
                  return _buildMessageBubble(msg, isMe, isDark);
                },
              ),
            ),
            _buildInputArea(isDark),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMe, bool isDark) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppConfig.primaryColor : (isDark ? AppConfig.surfaceDark : Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
          boxShadow: [
            if (!isMe) BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05), blurRadius: 5, offset: const Offset(0, 2))
          ],
          border: isMe ? null : Border.all(color: isDark ? AppConfig.borderDark : Colors.transparent),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg['content'] ?? '',
              style: TextStyle(color: isMe ? Colors.white : (isDark ? AppConfig.textMainDark : AppConfig.textMainLight), fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Juste maintenant', // Could format msg['createdAt']
              style: TextStyle(color: isMe ? Colors.white70 : (isDark ? AppConfig.textSubDark : Colors.grey), fontSize: 10),
            ),
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
        width: MediaQuery.of(context).size.width * 0.8,
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
                  Icon(Icons.local_offer_outlined, color: AppConfig.warning),
                  SizedBox(width: 8),
                  Text('PROPOSITION DE PRIX', style: TextStyle(fontWeight: FontWeight.bold, color: AppConfig.warning, fontSize: 12)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    msg['content'] ?? 'Offre de prix',
                    style: TextStyle(fontSize: 14, color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white12 : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text('Prix proposé', style: TextStyle(fontSize: 12, color: isDark ? AppConfig.textSubDark : Colors.grey)),
                        Text(
                          '${offer['amount']} FCFA',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppConfig.warning),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (status == 'PENDING' && !isMe)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _respondToOffer(msg['_id'], 'REJECT'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppConfig.error,
                              side: const BorderSide(color: AppConfig.error),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Refuser'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _respondToOffer(msg['_id'], 'ACCEPT'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConfig.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Accepter'),
                          ),
                        ),
                      ],
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: status == 'ACCEPTED' ? AppConfig.success.withValues(alpha: 0.1) : (status == 'REJECTED' ? AppConfig.error.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status == 'ACCEPTED' ? 'ACCEPTÉE' : (status == 'REJECTED' ? 'REFUSÉE' : 'EN ATTENTE'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          color: status == 'ACCEPTED' ? AppConfig.success : (status == 'REJECTED' ? AppConfig.error : Colors.grey)
                        ),
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

  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.surfaceDark : Colors.white,
        border: Border(top: BorderSide(color: isDark ? AppConfig.borderDark : Colors.grey[200]!)),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(icon: const Icon(Icons.add_circle_outline, color: AppConfig.primaryColor), onPressed: () {}),
            Expanded(
              child: TextField(
                controller: _messageController,
                style: TextStyle(color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight),
                decoration: InputDecoration(
                  hintText: 'Écrire un message...',
                  hintStyle: TextStyle(color: isDark ? AppConfig.textSubDark : Colors.grey[400], fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.white10 : Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(color: AppConfig.primaryColor, shape: BoxShape.circle),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: () {
                  if (_messageController.text.isNotEmpty) {
                    _sendMessage();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
