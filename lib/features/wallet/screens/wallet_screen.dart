import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/ganagaseva_button.dart';
import '../../../core/widgets/ganagaseva_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/transaction_card.dart';
import '../../../services/wallet_repository.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(walletRepositoryProvider);
    final wallet = state.wallet;
    final txs = state.transactions.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        actions: [
          IconButton(
            onPressed: () => context.push('/payment-methods'),
            icon: const Icon(Icons.account_balance_outlined),
            tooltip: 'Payment methods',
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ref.read(walletRepositoryProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: AppShadows.medium,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wallet Balance',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.warmCream.withValues(alpha: 0.85),
                        ),
                  ),
                  const SizedBox(height: 8),
                  AmountText(
                    amount: wallet.walletBalance,
                    fontSize: 36,
                    color: AppColors.white,
                    decimals: true,
                    animate: true,
                  ),
                  const SizedBox(height: 16),
                  GanagasevaButton(
                    label: 'Withdraw Money',
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.darkBrown,
                    useGradient: false,
                    onPressed: () => context.push('/withdraw'),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.06, end: 0),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _BalanceTile(
                    label: 'Available',
                    amount: wallet.availableBalance,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _BalanceTile(
                    label: 'Pending',
                    amount: wallet.pendingBalance,
                    color: AppColors.sacredGold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _BalanceTile(
              label: 'Total Earnings',
              amount: wallet.totalEarnings,
              color: AppColors.primary,
              wide: true,
            ),
            const SizedBox(height: 24),
            SectionHeader(
              title: 'Recent Transactions',
              actionLabel: 'See all',
              onAction: () => context.push('/transactions'),
            ),
            ...txs.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TransactionCard(
                  transaction: t,
                  onTap: () => context.push('/transactions/${t.id}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceTile extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool wide;

  const _BalanceTile({
    required this.label,
    required this.amount,
    required this.color,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    return GanagasevaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 8),
          AmountText(amount: amount, fontSize: wide ? 22 : 18, color: AppColors.textPrimary),
        ],
      ),
    );
  }
}
