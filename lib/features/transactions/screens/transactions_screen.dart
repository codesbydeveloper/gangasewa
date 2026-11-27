import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/transaction_card.dart';
import '../../../models/wallet.dart';
import '../../../services/wallet_repository.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final txs = ref.watch(walletRepositoryProvider).transactions;
    final filtered = txs.where((t) {
      return switch (_tab) {
        1 => t.type == TransactionType.credit,
        2 => t.type == TransactionType.debit,
        3 => t.type == TransactionType.withdrawal,
        4 => t.type == TransactionType.refund,
        _ => true,
      };
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                for (final (i, label) in ['All', 'Credits', 'Debits', 'Withdrawals', 'Refunds'].indexed)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AppFilterChip(
                      label: label,
                      selected: _tab == i,
                      onSelected: () => setState(() => _tab = i),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No transactions yet',
                    message: 'Your wallet activity will appear here.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => TransactionCard(
                      transaction: filtered[i],
                      onTap: () => context.push('/transactions/${filtered[i].id}'),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
