import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ganagaseva_button.dart';
import '../../../core/widgets/ganagaseva_card.dart';
import '../../../models/booking.dart';
import '../../../services/booking_repository.dart';

/// Lightweight Record tab — does NOT open the camera until the user taps Start.
/// Mounting [RecordingCameraScreen] inside IndexedStack was crashing the app
/// because the camera initialized as soon as the main shell loaded.
class RecordEntryScreen extends ConsumerWidget {
  const RecordEntryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(bookingRepositoryProvider);
    final active = bookings
        .where((b) =>
            b.status == BookingStatus.inProgress ||
            b.status == BookingStatus.upcoming ||
            b.status == BookingStatus.accepted)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Record Puja')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
        children: [
          GanagasevaCard(
            gradient: AppColors.heroGradient,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Capture seva moments',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.white,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You can switch between front and rear cameras while recording. Clips are combined into one video when you stop.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.warmCream.withValues(alpha: 0.9),
                      ),
                ),
                const SizedBox(height: 20),
                GanagasevaButton(
                  label: 'Start Recording',
                  icon: Icons.videocam_rounded,
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.darkBrown,
                  useGradient: false,
                  onPressed: () => context.push('/recording'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Record for a booking', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          if (active.isEmpty)
            GanagasevaCard(
              child: Text(
                'No upcoming or in-progress bookings right now. You can still start a free recording above.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            ...active.take(5).map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GanagasevaCard(
                  onTap: () => context.push('/recording/${b.id}'),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.softBeige,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.videocam_outlined, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b.pujaName, style: Theme.of(context).textTheme.titleSmall),
                            Text(
                              '${b.devotee.name} • ${b.bookingNumber}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          GanagasevaOutlinedButton(
            label: 'My Videos',
            icon: Icons.video_library_outlined,
            onPressed: () => context.push('/videos'),
          ),
        ],
      ),
    );
  }
}
