import 'package:flutter/material.dart';
import '../../../core/config.dart';

// ──────────────────────────── Data model ────────────────────────────
class _OfferData {
  final String id;
  final String price;
  final String route;
  final String distance;
  final String details;
  final String statusLabel;
  final Color statusColor;
  final String? refusalReason; // Motif pour les offres refusées

  const _OfferData({
    required this.id,
    required this.price,
    required this.route,
    required this.distance,
    required this.details,
    required this.statusLabel,
    required this.statusColor,
    this.refusalReason,
  });
}

// ──────────────────────────── Screen ────────────────────────────────
class TransporterOffersScreen extends StatefulWidget {
  const TransporterOffersScreen({super.key});

  @override
  State<TransporterOffersScreen> createState() => _TransporterOffersScreenState();
}

class _TransporterOffersScreenState extends State<TransporterOffersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data avec motifs de refus
  final List<_OfferData> _pending = const [
    _OfferData(id: '#045', price: '15 000', route: 'Bobo-Dioulasso → Ouagadougou', distance: '360 km', details: 'Maïs sec • 500 kg', statusLabel: 'EN ATTENTE', statusColor: Colors.orange),
    _OfferData(id: '#048', price: '5 500',  route: 'Koudougou → Ouagadougou',     distance: '100 km', details: 'Sorgho • 200 kg',   statusLabel: 'EN ATTENTE', statusColor: Colors.orange),
  ];

  final List<_OfferData> _accepted = const [
    _OfferData(id: '#041', price: '10 000', route: 'Koudougou → Ouagadougou', distance: '100 km', details: 'Tomates • 200 kg', statusLabel: 'ACCEPTÉE', statusColor: AppConfig.primaryColor),
  ];

  final List<_OfferData> _refused = const [
    _OfferData(id: '#039', price: '12 000', route: 'Ouahigouya → Ouagadougou', distance: '180 km', details: 'Oignons • 1 Tonne',  statusLabel: 'REFUSÉE', statusColor: Colors.red, refusalReason: 'Prix proposé trop bas par rapport à la distance.'),
    _OfferData(id: '#036', price: '25 000', route: 'Banfora → Ouagadougou',     distance: '450 km', details: 'Sucre • 2 Tonnes',   statusLabel: 'REFUSÉE', statusColor: Colors.red, refusalReason: 'Transporteur déjà sélectionné pour cette commande.'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── Modifier modal ───────────────────────────────────────────────
  void _showEditModal(_OfferData offer, bool isDark) {
    final controller = TextEditingController(text: offer.price);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppConfig.bgDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 24),
              Text('Modifier l\'offre ${offer.id}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Trajet : ${offer.route}', style: TextStyle(color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight)),
              const SizedBox(height: 24),
              Text('Nouveau prix (FCFA)', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? AppConfig.textMainDark : AppConfig.textMainLight)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppConfig.surfaceDark : Colors.grey[100],
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppConfig.borderDark : AppConfig.borderLight),
                ),
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    suffixText: 'FCFA',
                    suffixStyle: TextStyle(color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 52),
                        side: BorderSide(color: isDark ? AppConfig.borderDark : AppConfig.borderLight),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Annuler', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Offre ${offer.id} modifiée : ${controller.text} FCFA'),
                            backgroundColor: AppConfig.primaryColor,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConfig.primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text('Confirmer', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Retirer modal ────────────────────────────────────────────────
  void _showWithdrawModal(_OfferData offer, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppConfig.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Retirer l\'offre', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Voulez-vous vraiment retirer l\'offre ${offer.id} sur le trajet ${offer.route} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Offre ${offer.id} retirée.'),
                  backgroundColor: AppConfig.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConfig.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Retirer', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ─── Detail modal ─────────────────────────────────────────────────
  void _showDetailModal(_OfferData offer, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.5,
        maxChildSize: 0.92,
        builder: (_, sc) => Container(
          decoration: BoxDecoration(
            color: isDark ? AppConfig.bgDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: ListView(
            controller: sc,
            children: [
              // Drag handle
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              // Header : status + title + price badge
              _DetailHeader(offer: offer),
              const SizedBox(height: 28),
              // Info items
              _buildDetailItem(Icons.route_outlined,          'Trajet',           offer.route,     isDark),
              _buildDetailItem(Icons.straighten,              'Distance estimée', offer.distance,  isDark),
              _buildDetailItem(Icons.inventory_2_outlined,    'Marchandise',      offer.details,   isDark),
              _buildDetailItem(Icons.calendar_today_outlined, 'Date de l\'offre', '12 Mars 2024',  isDark),
              // Motif de refus — visible uniquement si refusée
              if (offer.refusalReason != null) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.cancel_outlined, color: Colors.red, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Motif du refus', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(offer.refusalReason!, style: TextStyle(fontSize: 13, color: isDark ? Colors.red[200] : Colors.red[900], height: 1.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConfig.primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Fermer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppConfig.bgDark : AppConfig.bgLight,
      appBar: AppBar(
        title: const Text('Mes offres', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppConfig.primaryColor,
          labelColor: AppConfig.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'En attente (2)'),
            Tab(text: 'Acceptées (1)'),
            Tab(text: 'Refusées (2)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(_pending, isDark),
          _buildList(_accepted, isDark),
          _buildList(_refused, isDark),
        ],
      ),
    );
  }

  Widget _buildList(List<_OfferData> offers, bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: offers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _buildOfferCard(offers[i], isDark),
    );
  }

  Widget _buildOfferCard(_OfferData offer, bool isDark) {
    return GestureDetector(
      onTap: () => _showDetailModal(offer, isDark),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppConfig.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppConfig.borderDark : AppConfig.borderLight),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(offer.statusLabel, style: TextStyle(color: offer.statusColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          const SizedBox(height: 4),
                          Text('Offre ${offer.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppConfig.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('${offer.price} FCFA',
                            style: const TextStyle(color: AppConfig.primaryColor, fontWeight: FontWeight.w900, fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.local_shipping_outlined, offer.route),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.straighten, offer.distance),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.inventory_2_outlined, offer.details),
                ],
              ),
            ),
            if (offer.statusLabel == 'EN ATTENTE')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: isDark ? AppConfig.borderDark : Colors.grey[100]!)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showEditModal(offer, isDark),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConfig.primaryColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text('Modifier', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showWithdrawModal(offer, isDark),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          side: BorderSide(color: isDark ? AppConfig.borderDark : Colors.grey[300]!),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          foregroundColor: isDark ? Colors.white : Colors.black87,
                        ),
                        child: const Text('Retirer', style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildDetailItem(IconData icon, String title, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppConfig.primaryColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(title, style: TextStyle(fontSize: 12, color: isDark ? AppConfig.textSubDark : AppConfig.textSubLight)),
                const SizedBox(height: 3),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey))),
      ],
    );
  }
}

// ──────────────────── Detail modal header (extracted) ────────────────
class _DetailHeader extends StatelessWidget {
  final _OfferData offer;
  const _DetailHeader({required this.offer});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(offer.statusLabel,
                  style: TextStyle(color: offer.statusColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 4),
              Text('Offre ${offer.id}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppConfig.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('${offer.price} FCFA',
              style: const TextStyle(color: AppConfig.primaryColor, fontWeight: FontWeight.w900, fontSize: 14)),
        ),
      ],
    );
  }
}
