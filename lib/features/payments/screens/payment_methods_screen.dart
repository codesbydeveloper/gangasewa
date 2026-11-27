import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/ganagaseva_button.dart';
import '../../../core/widgets/ganagaseva_card.dart';
import '../../../models/payment_method.dart';
import '../../../services/wallet_repository.dart';

class PaymentMethodsScreen extends ConsumerWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final methods = ref.watch(walletRepositoryProvider).paymentMethods;

    return Scaffold(
      appBar: AppBar(title: const Text('Payment Methods')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Payout accounts for seva earnings. Sensitive details are masked.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ...methods.map((m) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GanagasevaCard(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.softBeige,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        m.type == PaymentMethodType.upi
                            ? Icons.qr_code_2_rounded
                            : Icons.account_balance_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(m.displayName, style: Theme.of(context).textTheme.titleMedium),
                              if (m.isPrimary) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Primary',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(m.maskedDetail, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (v) async {
                        final repo = ref.read(walletRepositoryProvider.notifier);
                        if (v == 'primary') {
                          await repo.setPrimary(m.id);
                          return;
                        }
                        if (v == 'delete') {
                          final messenger = ScaffoldMessenger.of(context);
                          final ok = await ConfirmDialog.show(
                            context,
                            title: 'Remove account?',
                            message: 'This payout method will be removed.',
                            confirmLabel: 'Remove',
                            isDestructive: true,
                          );
                          if (ok == true) {
                            await repo.deletePaymentMethod(m.id);
                            messenger.showSnackBar(
                              const SnackBar(content: Text('Payment method removed')),
                            );
                          }
                        }
                      },
                      itemBuilder: (_) => [
                        if (!m.isPrimary)
                          const PopupMenuItem(value: 'primary', child: Text('Set as Primary')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          GanagasevaButton(
            label: 'Add Bank Account',
            icon: Icons.account_balance_outlined,
            onPressed: () => context.push('/add-bank'),
          ),
          const SizedBox(height: 10),
          GanagasevaOutlinedButton(
            label: 'Add UPI',
            icon: Icons.qr_code_2_rounded,
            onPressed: () => context.push('/add-upi'),
          ),
        ],
      ),
    );
  }
}
