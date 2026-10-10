import 'package:cargo_setu/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/marketplace_payment_model.dart';
import '../services/marketplace_service.dart';

/// Screen displaying the user company's marketplace escrow wallet balance,
/// held funds under active transit, and payout availability.
/// Zero internal database primary key exposure.
class MarketplaceWalletScreen extends StatefulWidget {
  const MarketplaceWalletScreen({super.key});

  @override
  State<MarketplaceWalletScreen> createState() => _MarketplaceWalletScreenState();
}

class _MarketplaceWalletScreenState extends State<MarketplaceWalletScreen> {
  final _service = MarketplaceService();
  bool _isLoading = true;
  WalletStatementModel? _wallet;

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    setState(() => _isLoading = true);
    final wallet = await _service.getWalletStatement();
    if (mounted) {
      setState(() {
        _wallet = wallet;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Marketplace Escrow Wallet',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _loadWallet,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadWallet,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceCard(currencyFormatter),
                    const SizedBox(height: 16),
                    _buildEscrowProtectionBanner(),
                    const SizedBox(height: 16),
                    _buildQuickActionButtons(),
                    const SizedBox(height: 16),
                    _buildSecurityGuaranteesCard(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBalanceCard(NumberFormat currencyFormatter) {
    final balance = _wallet?.balance ?? 0.0;
    final held = _wallet?.heldBalance ?? 0.0;
    final available = _wallet?.availableBalance ?? (balance - held);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F0F172A),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Total Ledger Balance',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Escrow Protected',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF34D399),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            currencyFormatter.format(balance),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Held In Escrow',
                        style: TextStyle(fontSize: 11, color: Colors.white60),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currencyFormatter.format(held),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFBBF24),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 28,
                  width: 1,
                  color: Colors.white24,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Available Payout',
                        style: TextStyle(fontSize: 11, color: Colors.white60),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currencyFormatter.format(available),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF34D399),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEscrowProtectionBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: Color(0xFF2563EB), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Automated Escrow Safeguard',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E40AF),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'When you accept a booking, shipper advance payments are locked in CargoSetu Escrow. Funds are automatically released to the transporter upon verified delivery and POD confirmation.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1E3A8A),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.add, color: Colors.white, size: 18),
            label: const Text(
              'Add Advance Funds',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            onPressed: () {
              Get.snackbar(
                'Add Funds',
                'Escrow funding is triggered automatically when confirming an accepted load offer.',
                backgroundColor: const Color(0xFF0F172A),
                colorText: Colors.white,
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.account_balance, color: Color(0xFF0F172A), size: 18),
            label: const Text(
              'Request Payout',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
            ),
            onPressed: () {
              Get.snackbar(
                'Payout Request',
                'Completed trip balances are settled to your linked bank account within 24 hours.',
                backgroundColor: const Color(0xFF0F172A),
                colorText: Colors.white,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityGuaranteesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CargoSetu Marketplace Guarantees',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 12),
          _GuaranteeItem(
            icon: Icons.check_circle_outline,
            title: '100% Guaranteed Transporter Payment',
            description: 'Transporters are guaranteed freight settlement once digital POD is submitted.',
          ),
          SizedBox(height: 10),
          _GuaranteeItem(
            icon: Icons.security,
            title: 'Shipper Transit Protection',
            description: 'Funds remain held securely if a vehicle fails to report or shipment is cancelled.',
          ),
          SizedBox(height: 10),
          _GuaranteeItem(
            icon: Icons.gavel,
            title: 'Dispute Arbitration',
            description: 'CargoSetu arbitrates detention, shortages, and claims before releasing held funds.',
          ),
        ],
      ),
    );
  }
}

class _GuaranteeItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _GuaranteeItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Color(0xFF059669)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
