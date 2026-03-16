import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agroconnect_bf/core/config.dart';
import 'package:agroconnect_bf/core/mock_data.dart';

class BuyerOrdersScreen extends StatelessWidget {
  const BuyerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
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
                "Commandes",
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
          bottom: TabBar(
            isScrollable: true,
            labelColor: AppConfig.primaryColor,
            unselectedLabelColor: isDark ? AppConfig.textSubDark : AppConfig.textSubLight,
            indicatorColor: AppConfig.primaryColor,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'En attente'),
              Tab(text: 'Confirmées'),
              Tab(text: 'En livraison'),
              Tab(text: 'Historique'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrdersList(context, statusGroup: 'AWAITING', isDark: isDark),
            _buildOrdersList(context, statusGroup: 'CONFIRMED', isDark: isDark),
            _buildOrdersList(context, statusGroup: 'SHIPPING', isDark: isDark),
            _buildOrdersList(context, statusGroup: 'HISTORY', isDark: isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, {required String statusGroup, required bool isDark}) {
    int count;
    switch (statusGroup) {
      case 'AWAITING': count = 2; break;
      case 'CONFIRMED': count = 1; break;
      case 'SHIPPING': count = 1; break;
      case 'HISTORY': count = 5; break;
      default: count = 0;
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: count,
      itemBuilder: (context, index) {
        String orderId;
        String status;
        String date = 'Aujourd\'hui';
        
        switch (statusGroup) {
          case 'AWAITING':
            orderId = '04${index + 1}';
            status = index == 0 ? 'EN ATTENTE DE CONFIRMATION' : 'PAIEMENT REQUIS';
            break;
          case 'CONFIRMED':
            orderId = '039';
            status = 'CONFIRMÉ';
            break;
          case 'SHIPPING':
            orderId = '042';
            status = 'EN COURS DE LIVRAISON';
            break;
          case 'HISTORY':
            orderId = '02${index + 1}';
            status = 'LIVRÉ';
            date = '10 Mars 2024';
            break;
          default:
            orderId = '000';
            status = 'INCONNU';
        }
        
        return _buildOrderItem(
          context,
          orderId: orderId,
          farmerName: 'Kaboré Amadou',
          productName: MockData.products[index % MockData.products.length].name,
          amount: '${(index + 1) * 25000} FCFA',
          status: status,
          date: date,
          statusGroup: statusGroup,
          isDark: isDark,
        );
      },
    );
  }

  Widget _buildOrderItem(
    BuildContext context, {
    required String orderId,
    required String farmerName,
    required String productName,
    required String amount,
    required String status,
    required String date,
    required String statusGroup,
    required bool isDark,
  }) {
    Color statusColor;
    if (status == 'LIVRÉ' || status == 'CONFIRMÉ') {
      statusColor = AppConfig.success;
    } else if (status == 'EN COURS DE LIVRAISON') {
      statusColor = AppConfig.info;
    } else if (status == 'PAIEMENT REQUIS') {
      statusColor = AppConfig.error;
    } else {
      statusColor = AppConfig.warning;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppConfig.borderDark : AppConfig.borderLight),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: InkWell(
        onTap: () {
          if (status == 'PAIEMENT REQUIS') {
            context.push('/buyer/orders/$orderId/payment');
          } else if (status == 'CONFIRMÉ' && statusGroup == 'CONFIRMED') {
            context.push('/buyer/orders/$orderId/transport');
          } else {
            context.push('/buyer/orders/$orderId');
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Commande #$orderId', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppConfig.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.agriculture_rounded, color: AppConfig.primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(farmerName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight)),
                        const SizedBox(height: 2),
                        Text(productName, style: TextStyle(color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight, fontSize: 13)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                       Text(amount, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppConfig.primaryColor)),
                       const SizedBox(height: 2),
                       Text(date, style: TextStyle(color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight, fontSize: 11)),
                    ],
                  ),
                ],
              ),
              if (status == 'PAIEMENT REQUIS') ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConfig.error.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppConfig.error.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       const Text(
                          'Action requise: Paiement',
                          style: TextStyle(color: AppConfig.error, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppConfig.error,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text('Payer', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ),
              ],
              if (status == 'CONFIRMÉ' && statusGroup == 'CONFIRMED') ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConfig.info.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppConfig.info.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_shipping_outlined, color: AppConfig.info, size: 20),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Choisir un transporteur',
                          style: TextStyle(color: AppConfig.info, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 14, color: AppConfig.info.withValues(alpha: 0.5)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
