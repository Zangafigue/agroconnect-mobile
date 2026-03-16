import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config.dart';
import '../../../core/models/product_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../messaging/providers/messaging_provider.dart';
import '../../orders/providers/order_provider.dart';
import '../../farmer/widgets/order_action_sheets.dart';
import '../widgets/withdrawal_modal.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppConfig.bgDark : AppConfig.bgLight,
      appBar: AppBar(
        title: Text('Commande #$orderId', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : AppConfig.textMainLight,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Status Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: AppConfig.primaryColor,
              child: const Column(
                children: [
                  Icon(Icons.info_outline, color: Colors.white, size: 40),
                  SizedBox(height: 12),
                  Text(
                    'En attente de confirmation',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Veuillez confirmer la disponibilité des produits',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ref.watch(orderDetailProvider(orderId)).when(
                data: (order) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Client Section
                    _buildSectionTitle('CLIENT'),                    _buildClientCard(
                      name: order.buyer != null ? '${order.buyer!.firstName} ${order.buyer!.lastName}' : 'Utilisateur inconnu',
                      location: order.deliveryAddress,
                      phone: order.buyer?.phone ?? 'Non spécifié',
                      onCall: () {},
                      onMessage: () async {
                        try {
                          final repo = ref.read(messagingRepositoryProvider);
                          final auth = ref.read(authProvider);
                          final role = auth.role;
                          
                          // Si c'est le vendeur qui regarde, il contacte l'acheteur
                          // Si c'est l'acheteur qui regarde, il contacte le vendeur (agriculteur)
                          final recipientId = (role == 'FARMER') ? order.buyer?.id : order.seller?.id;
                          if (recipientId == null) return;

                          final chat = await repo.startConversation(recipientId, orderId: order.id);
                          if (context.mounted) {
                            final prefix = role == 'FARMER' ? '/farmer' : '/buyer';
                            context.push('$prefix/messages/${chat['_id']}');
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Product Summary
                    _buildSectionTitle('DÉTAILS DU PRODUIT'),
                    if (order.product != null)
                      _buildProductSummaryCard(
                        product: order.product!,
                        quantity: order.quantity,
                        total: '${order.totalPrice.toInt()} FCFA',
                      )
                    else
                      const Center(child: Text('Produit non trouvé')),
                    const SizedBox(height: 24),
                    
                    // Status Timeline
                    _buildSectionTitle('SUIVI DE COMMANDE'),
                    _buildTimelineItem(
                      context,
                      title: 'Commande passée',
                      subtitle: 'Status: ${order.status}',
                      isFirst: true,
                      isLast: false,
                      isCompleted: true,
                    ),
                    _buildTimelineItem(
                      context,
                      title: 'Confirmation vendeur',
                      subtitle: 'En attente de votre action',
                      isFirst: false,
                      isLast: true, // This is the last item in the provided diff
                      isCurrent: true,
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Erreur: $e')),
              ),
            ),
            const SizedBox(height: 100), // Space for action buttons
          ],
        ),
      ),
       bottomSheet: ref.watch(orderDetailProvider(orderId)).when(
        data: (order) => Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppConfig.surfaceDark : Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => OrderActionSheets.showRefusalSheet(
                    context, 
                    orderId: orderId, 
                    buyerName: order.buyer != null ? '${order.buyer!.firstName} ${order.buyer!.lastName}' : 'le client'
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConfig.error,
                    side: const BorderSide(color: AppConfig.error),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Refuser', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => OrderActionSheets.showConfirmationSheet(
                    context, 
                    orderId: orderId, 
                    buyerName: order.buyer != null ? '${order.buyer!.firstName} ${order.buyer!.lastName}' : 'le client', 
                    product: order.product?.name ?? 'le produit'
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConfig.primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Confirmer', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildClientCard({
    required String name,
    required String location,
    required String phone,
    required VoidCallback onCall,
    required VoidCallback onMessage,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppConfig.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppConfig.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: AppConfig.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 2),
                Text(location, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
          Row(
            children: [
              _buildCircularAction(Icons.phone, Colors.blue, onCall),
              const SizedBox(width: 8),
              _buildCircularAction(Icons.chat_bubble, AppConfig.primaryColor, onMessage),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircularAction(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildProductSummaryCard({
    required Product product,
    required int quantity,
    required String total,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppConfig.borderLight),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(product.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('${product.price} FCFA / ${product.unit}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ),
              Text('x$quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total (incl. frais liv.)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              Text(total, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppConfig.primaryColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    bool isFirst = false,
    bool isLast = false,
    bool isCompleted = false,
    bool isCurrent = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 70,
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                if (!isFirst) Expanded(child: Container(width: 2, color: isCompleted ? AppConfig.primaryColor : (isDark ? AppConfig.borderDark : Colors.grey[200]))),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isCompleted ? AppConfig.primaryColor : (isCurrent ? (isDark ? AppConfig.surfaceDark : Colors.white) : (isDark ? AppConfig.borderDark : Colors.grey[200])),
                    shape: BoxShape.circle,
                    border: isCurrent ? Border.all(color: AppConfig.primaryColor, width: 4) : null,
                  ),
                  child: isCompleted ? const Icon(Icons.check, color: Colors.white, size: 10) : null,
                ),
                if (!isLast) Expanded(child: Container(width: 2, color: isCompleted ? AppConfig.primaryColor : (isDark ? AppConfig.borderDark : Colors.grey[200]))),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isCurrent ? AppConfig.primaryColor : (isDark ? Colors.white : Colors.black))),
                Text(subtitle, style: TextStyle(color: isDark ? AppConfig.textSubDark : Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessagingScreen extends ConsumerWidget {
  const MessagingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppConfig.bgDark : AppConfig.bgLight,
      appBar: AppBar(
        title: const Text('Messagerie', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : AppConfig.textMainLight,
      ),
      body: Column(
        children: [
          // Filter Tabs (Optional)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip(context, 'Tout', true),
                const SizedBox(width: 8),
                _buildFilterChip(context, 'Achats', false),
                const SizedBox(width: 8),
                _buildFilterChip(context, 'Transports', false),
              ],
            ),
          ),
          
          Expanded(
            child: ref.watch(conversationsProvider).when(
              data: (conversations) {
                if (conversations.isEmpty) {
                  return const Center(child: Text("Aucune conversation"));
                }
                final authState = ref.watch(authProvider);
                final currentUserId = authState.user?.id;

                return ListView.separated(
                  itemCount: conversations.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, indent: 70),
                  itemBuilder: (context, index) {
                    final chat = conversations[index];
                    final List participants = chat['participants'] ?? [];
                    final otherParticipant = participants.firstWhere(
                      (p) => p is Map && p['_id'] != currentUserId,
                      orElse: () => {'firstName': 'Utilisateur'}
                    );
                    final lastMessage = chat['lastMessage'] ?? {};

                    return _buildChatTile(
                      context,
                      name: '${otherParticipant['firstName'] ?? 'Utilisateur'} ${otherParticipant['lastName'] ?? ''}',
                      lastMessage: lastMessage['content'] ?? 'Nouvelle conversation',
                      time: 'Logistique', // Could be formatted from updatedAt
                      unreadCount: 0,
                      chatId: chat['_id'] ?? '',
                      isNegotiation: chat['type'] == 'NEGOTIATION',
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, bool isSelected) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? AppConfig.primaryColor : (isDark ? AppConfig.surfaceDark : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? AppConfig.primaryColor : (isDark ? AppConfig.borderDark : AppConfig.borderLight)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : (isDark ? AppConfig.textSubDark : Colors.grey[600]),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildChatTile(
    BuildContext context, {
    required String name,
    required String lastMessage,
    required String time,
    required int unreadCount,
    required String chatId,
    bool isNegotiation = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      onTap: () => context.push('/farmer/messages/$chatId'),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppConfig.primaryColor.withValues(alpha: 0.1),
            child: Text(name.substring(0, 1), style: const TextStyle(color: AppConfig.primaryColor, fontWeight: FontWeight.bold)),
          ),
          if (unreadCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Text(time, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
        ],
      ),
      subtitle: Row(
        children: [
          if (isNegotiation)
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Icon(Icons.gavel, size: 14, color: AppConfig.warning.withValues(alpha: 0.7)),
            ),
          Expanded(
            child: Text(
              lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: unreadCount > 0 ? (isDark ? Colors.white : AppConfig.textMainLight) : (isDark ? AppConfig.textSubDark : Colors.grey),
                fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isFarmer = authState.role == 'FARMER';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!isFarmer) {
      return Scaffold(
        backgroundColor: isDark ? AppConfig.bgDark : AppConfig.bgLight,
        appBar: AppBar(
          title: const Text('Mon Portefeuille'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: isDark ? Colors.white : AppConfig.textMainLight,
        ),
        body: const Center(child: Text('Solde actuel et demande de retrait')),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppConfig.bgDark : AppConfig.bgLight,
      appBar: AppBar(
        title: const Text('💰 Mon portefeuille', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : AppConfig.textMainLight,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildWalletStatCard(
                      context,
                      label: 'Disponible',
                      amount: '185 000 FCFA',
                      color: AppConfig.success,
                      icon: Icons.check_circle_outline,
                      status: 'PRÊT',
                      backgroundColor: AppConfig.success.withValues(alpha: isDark ? 0.2 : 0.1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildWalletStatCard(
                      context,
                      label: 'En attente',
                      amount: '485 000 FCFA',
                      color: AppConfig.warning,
                      icon: Icons.schedule,
                      status: 'TRAITEMENT',
                      backgroundColor: AppConfig.warning.withValues(alpha: isDark ? 0.2 : 0.1),
                    ),
                  ),
                ],
              ),
            ),
            // Main Action
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const WithdrawalModal(),
                      );
                    },
                    icon: const Icon(Icons.payments),
                    label: const Text('Retirer mes fonds', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConfig.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      shadowColor: AppConfig.primaryColor.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Retrait vers Orange Money, Moov Money ou compte bancaire',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(height: 8, color: AppConfig.primaryColor.withValues(alpha: 0.05)),
            // Transaction History
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Historique des transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Voir tout', style: TextStyle(color: AppConfig.primaryColor, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTransactionItem(
                    context,
                    title: 'Cmde #035 Fatima T.',
                    subtitle: 'libéré · 07 mars',
                    amount: '+242 500 FCFA',
                    isPending: false,
                  ),
                  _buildTransactionItem(
                    context,
                    title: 'Cmde #031 Ibrahim S.',
                    subtitle: 'libéré · 04 mars',
                    amount: '+ 67 900 FCFA',
                    isPending: false,
                  ),
                  _buildTransactionItem(
                    context,
                    title: 'Cmde #041 Ibrahim S.',
                    subtitle: 'en attente',
                    amount: '+ 67 900 FCFA',
                    isPending: true,
                  ),
                  _buildTransactionItem(
                    context,
                    title: 'Cmde #045 Fatima T.',
                    subtitle: 'en attente',
                    amount: '+485 000 FCFA',
                    isPending: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletStatCard(
    BuildContext context, {
    required String label,
    required String amount,
    required Color color,
    required IconData icon,
    required String status,
    required Color backgroundColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(amount, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(icon, size: 14, color: color.withValues(alpha: 0.8)),
              const SizedBox(width: 4),
              Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color.withValues(alpha: 0.8), letterSpacing: 1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String amount,
    required bool isPending,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppConfig.borderDark : AppConfig.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isPending ? AppConfig.warning : AppConfig.success).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPending ? Icons.lock : Icons.check_circle,
              color: isPending ? AppConfig.warning : AppConfig.success,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isPending ? AppConfig.warning : (isDark ? AppConfig.textSubDark : AppConfig.textSubLight),
                    fontWeight: isPending ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isPending ? (isDark ? AppConfig.textSubDark : AppConfig.textSubLight) : AppConfig.success,
            ),
          ),
        ],
      ),
    );
  }
}


// ProfileScreen has been replaced by FarmerProfileScreen and BuyerProfileScreen
// in their respective feature modules for better role-specific functionality.
