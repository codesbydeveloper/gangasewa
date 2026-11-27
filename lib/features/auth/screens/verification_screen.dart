import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ganagaseva_button.dart';
import '../../../services/auth_repository.dart';

class VerificationScreen extends ConsumerWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  color: AppColors.sacredGold.withValues(alpha: 0.15),
                ),
                child: const Icon(Icons.hourglass_top_rounded, size: 48, color: AppColors.sacredGold),
              ).animate().fadeIn().scale(),
              const SizedBox(height: 28),
              Text(
                'Verification Pending',
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Thank you, Pandit Ji. Our team is reviewing your profile. You will be notified once approved.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              ),
              const Spacer(),
              GanagasevaButton(
                label: 'Simulate Approval (Demo)',
                onPressed: () async {
                  await ref.read(authRepositoryProvider.notifier).approveVerification();
                  if (context.mounted) context.go('/verification-approved');
                },
              ),
              const SizedBox(height: 12),
              GanagasevaOutlinedButton(
                label: 'Continue to Dashboard',
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VerificationApprovedScreen extends StatelessWidget {
  const VerificationApprovedScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                child: const Icon(Icons.verified_rounded, size: 56, color: AppColors.success),
              ).animate().scale(curve: Curves.easeOutBack),
              const SizedBox(height: 28),
              Text(
                'You are Verified!',
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Your Ganagaseva profile is approved. Start accepting seva bookings with confidence.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
              ),
              const Spacer(),
              GanagasevaButton(
                label: 'Go to Dashboard',
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
