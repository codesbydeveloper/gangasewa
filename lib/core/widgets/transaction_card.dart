import 'package:flutter/material.dart';
import '../../models/wallet.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import 'ganagaseva_card.dart';

class TransactionCard extends StatelessWidget {
  final WalletTransaction transaction;
  final VoidCallback? onTap;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
  });

  Color get _amountColor {
    if (transaction.status == TransactionStatus.pending) return AppColors.sacredGold;
    if (transaction.isCredit) return AppColors.success;
    return AppColors.error;
  }

  IconData get _icon => switch (transaction.type) {
        TransactionType.credit => Icons.south_west_rounded,
        TransactionType.refund => Icons.replay_rounded,
        TransactionType.withdrawal => Icons.account_balance_outlined,
        TransactionType.debit => Icons.north_east_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final sign = transaction.isCredit ? '+' : '-';
    return GanagasevaCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _amountColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_icon, color: _amountColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  [
                    if (transaction.bookingId != null) transaction.bookingId!,
                    Formatters.dateTime(transaction.date),
                  ].join(' • '),
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign${Formatters.currency(transaction.amount)}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: _amountColor,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                transaction.status.name[0].toUpperCase() +
                    transaction.status.name.substring(1),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: transaction.status == TransactionStatus.pending
                          ? AppColors.sacredGold
                          : AppColors.textMuted,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
