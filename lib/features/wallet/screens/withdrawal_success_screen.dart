import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/ganagaseva_button.dart';

class WithdrawalSuccessScreen extends StatelessWidget {
  final double amount;
  const WithdrawalSuccessScreen({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    final settlement = DateTime.now().add(const Duration(days: 2));
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success.withValues(alpha: 0.15),
                ),
                child: const Icon(Icons.check_rounded, size: 56, color: AppColors.success),
              ).animate().scale(curve: Curves.easeOutBack),
              const SizedBox(height: 24),
              Text('Withdrawal Requested', style: Theme.of(context).textTheme.displaySmall, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(
                Formatters.currency(amount),
                style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              Text(
                'Expected settlement by ${Formatters.date(settlement)}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              GanagasevaButton(label: 'Back to Wallet', onPressed: () => context.go('/wallet')),
              const SizedBox(height: 10),
              GanagasevaOutlinedButton(
                label: 'View Transactions',
                onPressed: () => context.go('/transactions'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
