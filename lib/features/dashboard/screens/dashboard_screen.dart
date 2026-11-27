import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/booking_card.dart';
import '../../../core/widgets/ganagaseva_card.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../models/booking.dart';
import '../../../services/auth_repository.dart';
import '../../../services/booking_repository.dart';
import '../../../services/notification_repository.dart';
import '../../../services/wallet_repository.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pandit = ref.watch(authRepositoryProvider).pandit;
    final bookings = ref.watch(bookingRepositoryProvider);
    final wallet = ref.watch(walletRepositoryProvider).wallet;
    final unread = ref.watch(unreadNotificationCountProvider);
    final repo = ref.read(bookingRepositoryProvider.notifier);
    final today = repo.today();
    final upcoming = repo.upcoming().take(5).toList();

    final completed = bookings.where((b) => b.status == BookingStatus.completed).length;
    final cancelled = bookings.where((b) => b.status == BookingStatus.cancelled).length;
    final pending = bookings.where((b) => b.status == BookingStatus.pending).length;

    return Scaffold(
      body: SafeArea(
        child: _loading
            ? const DashboardShimmer()
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  await ref.read(bookingRepositoryProvider.notifier).refresh();
                  await ref.read(walletRepositoryProvider.notifier).refresh();
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ProfileAvatar(
                                  name: pandit?.name ?? 'Pandit',
                                  showVerified: pandit?.isVerified ?? false,
                                  size: 52,
                                  onTap: () => context.go('/profile'),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Namaste, Pandit Ji 🙏',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                      Text(
                                        pandit?.name ?? 'Pandit',
                                        style: Theme.of(context).textTheme.headlineSmall,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Stack(
                                  children: [
                                    IconButton(
                                      onPressed: () => context.push('/notifications'),
                                      icon: const Icon(Icons.notifications_outlined),
                                      iconSize: 26,
                                    ),
                                    if (unread > 0)
                                      Positioned(
                                        right: 10,
                                        top: 10,
                                        child: Container(
                                          width: 9,
                                          height: 9,
                                          decoration: const BoxDecoration(
                                            color: AppColors.error,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ).animate().fadeIn(),
                            const SizedBox(height: 20),
                            _EarningsHero(wallet: wallet),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _MiniStat(
                                    label: 'Wallet',
                                    value: Formatters.currency(wallet.availableBalance),
                                    icon: Icons.account_balance_wallet_outlined,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _MiniStat(
                                    label: 'Pending',
                                    value: Formatters.currency(wallet.pendingBalance),
                                    icon: Icons.hourglass_bottom_rounded,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _MiniStat(
                                    label: 'Completed Seva',
                                    value: '$completed',
                                    icon: Icons.check_circle_outline,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _MiniStat(
                                    label: 'Upcoming',
                                    value: '${upcoming.length}',
                                    icon: Icons.event_available_outlined,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const SectionHeader(title: 'Quick Actions'),
                            _QuickActions(),
                            const SizedBox(height: 24),
                            SectionHeader(
                              title: "Today's Schedule",
                              actionLabel: 'See all',
                              onAction: () => context.go('/bookings'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (today.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GanagasevaCard(
                            child: Text(
                              'No seva scheduled for today. Enjoy a peaceful day.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList.separated(
                          itemCount: today.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (_, i) => BookingCard(
                            booking: today[i],
                            onTap: () => context.push('/bookings/${today[i].id}'),
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                        child: SectionHeader(
                          title: 'Upcoming Bookings',
                          actionLabel: 'View',
                          onAction: () => context.go('/bookings'),
                        ),
                      ),
                    ),
                    if (upcoming.isNotEmpty)
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 150,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            scrollDirection: Axis.horizontal,
                            itemCount: upcoming.length,
                            separatorBuilder: (_, _) => const SizedBox(width: 12),
                            itemBuilder: (_, i) {
                              final b = upcoming[i];
                              return SizedBox(
                                width: 280,
                                child: BookingCard(
                                  booking: b,
                                  compact: true,
                                  onTap: () => context.push('/bookings/${b.id}'),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionHeader(title: 'Performance'),
                            Row(
                              children: [
                                Expanded(
                                  child: StatCard(
                                    label: 'Total',
                                    value: '${bookings.length}',
                                    icon: Icons.grid_view_rounded,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: StatCard(
                                    label: 'Completed',
                                    value: '$completed',
                                    icon: Icons.task_alt_rounded,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: StatCard(
                                    label: 'Cancelled',
                                    value: '$cancelled',
                                    icon: Icons.cancel_outlined,
                                    color: AppColors.error,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: StatCard(
                                    label: 'Pending',
                                    value: '$pending',
                                    icon: Icons.pending_actions_outlined,
                                    color: AppColors.warning,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            GanagasevaCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Weekly Seva', style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 140,
                                    child: BarChart(
                                      BarChartData(
                                        alignment: BarChartAlignment.spaceAround,
                                        maxY: 6,
                                        gridData: const FlGridData(show: false),
                                        borderData: FlBorderData(show: false),
                                        titlesData: FlTitlesData(
                                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget: (v, _) {
                                                const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                                                return Text(
                                                  days[v.toInt() % 7],
                                                  style: Theme.of(context).textTheme.labelSmall,
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        barGroups: [
                                          for (var i = 0; i < 7; i++)
                                            BarChartGroupData(
                                              x: i,
                                              barRods: [
                                                BarChartRodData(
                                                  toY: [3.0, 4.0, 2.0, 5.0, 3.0, 4.0, 2.0][i],
                                                  color: i == DateTime.now().weekday - 1
                                                      ? AppColors.primary
                                                      : AppColors.sacredGold.withValues(alpha: 0.55),
                                                  width: 14,
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _EarningsHero extends StatelessWidget {
  final dynamic wallet;
  const _EarningsHero({required this.wallet});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "This Month's Earnings",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.warmCream.withValues(alpha: 0.85),
                ),
          ),
          const SizedBox(height: 8),
          AmountText(
            amount: wallet.thisMonthEarnings,
            fontSize: 36,
            color: AppColors.white,
            animate: true,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${Formatters.percentChange(wallet.monthGrowthPercent)} vs last month',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08, end: 0);
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MiniStat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GanagasevaCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                Text(label, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.add_circle_outline, 'New Booking', () => context.push('/bookings-create')),
      (Icons.videocam_outlined, 'Record Puja', () => context.push('/recording')),
      (Icons.video_library_outlined, 'My Videos', () => context.push('/videos')),
      (Icons.payments_outlined, 'Withdraw', () => context.push('/withdraw')),
    ];

    return Row(
      children: actions.map((a) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GanagasevaCard(
              onTap: a.$3,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
              child: Column(
                children: [
                  Icon(a.$1, color: AppColors.primary, size: 24),
                  const SizedBox(height: 8),
                  Text(
                    a.$2,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
