import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/ganagaseva_card.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../services/auth_repository.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pandit = ref.watch(authRepositoryProvider).pandit;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          GanagasevaCard(
            gradient: AppColors.heroGradient,
            child: Row(
              children: [
                ProfileAvatar(
                  name: pandit?.name ?? 'Pandit',
                  showVerified: pandit?.isVerified ?? false,
                  size: 72,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pandit?.name ?? 'Pandit',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.white,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pandit?.isVerified == true ? 'Verified Pandit' : 'Verification Pending',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.sacredGold,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${pandit?.experienceYears ?? 0}+ years experience',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.warmCream.withValues(alpha: 0.85),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _tile(context, Icons.person_outline, 'Personal Information', () => context.push('/edit-profile')),
          _tile(context, Icons.work_outline, 'Professional Information', () => context.push('/edit-profile')),
          _tile(context, Icons.local_fire_department_outlined, 'Puja Services', () => context.push('/services')),
          _tile(context, Icons.account_balance_outlined, 'Bank Details', () => context.push('/payment-methods')),
          _tile(context, Icons.payments_outlined, 'Payment Settings', () => context.push('/payment-methods')),
          _tile(context, Icons.calendar_month_outlined, 'Availability', () => context.push('/availability')),
          _tile(context, Icons.notifications_outlined, 'Notifications', () => context.push('/notifications')),
          _tile(context, Icons.language, 'Language', () => context.push('/settings')),
          _tile(context, Icons.lock_outline, 'Privacy & Security', () => context.push('/settings')),
          _tile(context, Icons.help_outline, 'Help & Support', () => context.push('/help')),
          _tile(context, Icons.description_outlined, 'Terms & Conditions', () => context.push('/help')),
          const SizedBox(height: 12),
          GanagasevaCard(
            onTap: () async {
              final ok = await ConfirmDialog.show(
                context,
                title: 'Logout?',
                message: 'You will need to sign in again to manage seva bookings.',
                confirmLabel: 'Logout',
                isDestructive: true,
              );
              if (ok == true) {
                await ref.read(authRepositoryProvider.notifier).logout();
                if (context.mounted) context.go('/login');
              }
            },
            child: Row(
              children: [
                const Icon(Icons.logout_rounded, color: AppColors.error),
                const SizedBox(width: 12),
                Text(
                  'Logout',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.error),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GanagasevaCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: Theme.of(context).textTheme.titleSmall)),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
