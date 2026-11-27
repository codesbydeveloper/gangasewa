import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/ganagaseva_button.dart';
import '../../../core/widgets/ganagaseva_card.dart';
import '../../../services/wallet_repository.dart';

class WithdrawScreen extends ConsumerStatefulWidget {
  const WithdrawScreen({super.key});

  @override
  ConsumerState<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends ConsumerState<WithdrawScreen> {
  final _amount = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletRepositoryProvider).wallet;
    final methods = ref.watch(walletRepositoryProvider).paymentMethods;
    final primary = methods.firstWhere((m) => m.isPrimary, orElse: () => methods.first);
    final value = double.tryParse(_amount.text) ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Withdraw Money')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Available Balance', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(
            Formatters.currency(wallet.availableBalance, decimals: true),
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _amount,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: Theme.of(context).textTheme.headlineMedium,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: '₹ ',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final q in [1000, 5000, 10000])
                ActionChip(
                  label: Text('₹$q'),
                  onPressed: () => setState(() => _amount.text = '$q'),
                ),
              ActionChip(
                label: const Text('Maximum'),
                onPressed: () => setState(
                  () => _amount.text = wallet.availableBalance.toInt().toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GanagasevaCard(
            onTap: () => context.push('/payment-methods'),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.softBeige,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.account_balance, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(primary.displayName, style: Theme.of(context).textTheme.titleMedium),
                      Text(primary.maskedDetail, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
          const SizedBox(height: 32),
          GanagasevaButton(
            label: value > 0 ? 'Withdraw ${Formatters.currency(value)}' : 'Withdraw',
            isLoading: _loading,
            onPressed: value <= 0 || value > wallet.availableBalance
                ? null
                : () async {
                    final confirmed = await PrimaryBottomSheet.show<bool>(
                      context,
                      title: 'Confirm Withdrawal',
                      subtitle: 'Withdraw ${Formatters.currency(value)} to ${primary.displayName} ${primary.maskedDetail}?',
                      child: const SizedBox.shrink(),
                      footer: Column(
                        children: [
                          GanagasevaButton(
                            label: 'Confirm',
                            onPressed: () => Navigator.pop(context, true),
                          ),
                          const SizedBox(height: 8),
                          GanagasevaOutlinedButton(
                            label: 'Cancel',
                            onPressed: () => Navigator.pop(context, false),
                          ),
                        ],
                      ),
                    );
                    if (confirmed != true) return;
                    setState(() => _loading = true);
                    final ok = await ref.read(walletRepositoryProvider.notifier).withdraw(value);
                    setState(() => _loading = false);
                    if (ok && context.mounted) {
                      context.push('/withdraw-success', extra: value);
                    }
                  },
          ),
        ],
      ),
    );
  }
}
