import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config.dart';
import '../../notifications/providers/notification_provider.dart';
import '../../auth/providers/auth_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _getIcon(String type) {
    switch (type) {
      case 'MESSAGE':
        return Icons.chat_bubble_outline;
      case 'ORDER_STATUS':
        return Icons.inventory_2_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'MESSAGE':
        return AppConfig.primaryColor;
      case 'ORDER_STATUS':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.parse(timestamp);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    return DateFormat('dd/MM HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notificationsAsync = ref.watch(notificationsProvider);

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
              "Notifications",
              style: TextStyle(
                color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () async {
              try {
                await ref.read(notificationRepositoryProvider).markAllAsRead();
                ref.invalidate(notificationsProvider);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                }
              }
            },
            child: const Text('Tout marquer lu', style: TextStyle(color: AppConfig.primaryColor, fontSize: 12)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(child: Text("Aucune notification"));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(notificationsProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];
                final isRead = item['isRead'] == true;
                final type = item['type'] as String? ?? 'SYSTEM';

                return InkWell(
                  onTap: () async {
                    if (!isRead) {
                      try {
                        await ref.read(notificationRepositoryProvider).markAsRead(item['_id']);
                        ref.invalidate(notificationsProvider);
                      } catch (_) {}
                    }
                    
                    final relatedId = item['relatedId'];
                    if (relatedId == null) return;

                    final user = ref.read(authProvider).user;
                    if (user == null) return;

                    final role = user.role.toLowerCase();
                    
                    if (type == 'MESSAGE') {
                      if (context.mounted) {
                        context.push('/$role/messages/$relatedId');
                      }
                    } else if (type == 'ORDER_STATUS') {
                      final path = role == 'transporter' 
                        ? '/transporter/deliveries/$relatedId'
                        : '/$role/orders/$relatedId';
                      if (context.mounted) {
                        context.push(path);
                      }
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: !isRead
                          ? (isDark ? AppConfig.primaryColor.withValues(alpha: 0.1) : AppConfig.primaryColor.withValues(alpha: 0.05))
                          : (isDark ? Colors.white.withValues(alpha: 0.02) : Colors.white),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: !isRead ? AppConfig.primaryColor.withValues(alpha: 0.2) : Colors.transparent,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _getColor(type).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_getIcon(type), color: _getColor(type), size: 24),
                      ),
                      title: Text(
                        item['title'] as String? ?? '',
                        style: TextStyle(
                          fontWeight: !isRead ? FontWeight.bold : FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            item['message'] as String? ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatTime(item['createdAt']),
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, __) => Center(child: Text('Erreur: $err')),
      ),
    );
  }
}
