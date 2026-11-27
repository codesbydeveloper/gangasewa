import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/ganagaseva_card.dart';
import '../../../models/wallet.dart';
import '../../../services/wallet_repository.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final String transactionId;
  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tx = ref.watch(walletRepositoryProvider.notifier).transactionById(transactionId);
    if (tx == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Transaction')),
        body: const Center(child: Text('Transaction not found')),
      );
    }

    final color = tx.status == TransactionStatus.pending
        ? AppColors.sacredGold
        : tx.isCredit
            ? AppColors.success
            : AppColors.error;

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GanagasevaCard(
            child: Column(
              children: [
                Text(tx.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                AmountText(
                  amount: tx.amount,
                  fontSize: 32,
                  color: color,
                ),
                const SizedBox(height: 4),
                Text(
                  '${tx.isCredit ? '+' : '-'} ${tx.type.name.toUpperCase()}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GanagasevaCard(
            child: Column(
              children: [
                _row(context, 'Transaction ID', tx.id),
                if (tx.bookingId != null) _row(context, 'Booking ID', tx.bookingId!),
                _row(context, 'Date', Formatters.dateTime(tx.date)),
                _row(context, 'Payment Method', tx.paymentMethod ?? '—'),
                _row(context, 'Status', tx.status.name),
                if (tx.settlementDate != null)
                  _row(context, 'Settlement', Formatters.date(tx.settlementDate!)),
                if (tx.description != null) _row(context, 'Description', tx.description!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(k, style: Theme.of(context).textTheme.bodySmall)),
          Expanded(child: Text(v, style: Theme.of(context).textTheme.titleSmall)),
        ],
      ),
    );
  }
}
