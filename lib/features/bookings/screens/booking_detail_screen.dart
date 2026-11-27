import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/amount_text.dart';
import '../../../core/widgets/ganagaseva_button.dart';
import '../../../core/widgets/ganagaseva_card.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../models/booking.dart';
import '../../../services/booking_repository.dart';

class BookingDetailScreen extends ConsumerWidget {
  final String bookingId;
  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(bookingRepositoryProvider.notifier).byId(bookingId);
    if (booking == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Booking')),
        body: const Center(child: Text('Booking not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: 'booking_${booking.id}',
          child: Material(
            color: Colors.transparent,
            child: Text(booking.bookingNumber),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/bookings/${booking.id}/edit'),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(booking.pujaName, style: Theme.of(context).textTheme.headlineMedium),
              ),
              StatusBadge.booking(booking.status),
            ],
          ),
          const SizedBox(height: 20),
          _Section(
            title: 'DEVOTEE',
            child: Row(
              children: [
                ProfileAvatar(name: booking.devotee.name, size: 56),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.devotee.name, style: Theme.of(context).textTheme.titleMedium),
                      Text(Formatters.maskPhone(booking.devotee.phone),
                          style: Theme.of(context).textTheme.bodyMedium),
                      if (booking.devotee.email != null)
                        Text(booking.devotee.email!, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _Section(
            title: 'FAMILY DETAILS',
            child: Column(
              children: [
                _kv(context, 'Gotra', booking.devotee.gotra ?? '—'),
                _kv(context, 'Nakshatra', booking.devotee.nakshatra ?? '—'),
                _kv(context, 'Rashi', booking.devotee.rashi ?? '—'),
                _kv(
                  context,
                  'Family',
                  booking.devotee.familyMembers.isEmpty
                      ? '—'
                      : booking.devotee.familyMembers.join(', '),
                ),
              ],
            ),
          ),
          _Section(
            title: 'PUJA DETAILS',
            child: Column(
              children: [
                _kv(context, 'Puja Type', booking.pujaType),
                _kv(context, 'Date', Formatters.date(booking.scheduledAt)),
                _kv(context, 'Time', Formatters.time(booking.scheduledAt)),
                _kv(context, 'Duration', '${booking.duration.inMinutes} mins'),
                _kv(context, 'Location', booking.location),
                if (booking.address != null) _kv(context, 'Address', booking.address!),
                if (booking.specialInstructions != null)
                  _kv(context, 'Instructions', booking.specialInstructions!),
              ],
            ),
          ),
          if (booking.samagri.isNotEmpty)
            _Section(
              title: 'SAMAGRI',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: booking.samagri
                    .map((s) => Chip(
                          label: Text(s),
                          backgroundColor: AppColors.softBeige,
                          side: const BorderSide(color: AppColors.border),
                        ))
                    .toList(),
              ),
            ),
          _Section(
            title: 'PAYMENT',
            child: Column(
              children: [
                _kv(context, 'Service Amount', Formatters.currency(booking.amount)),
                _kv(context, 'Platform Fee', Formatters.currency(booking.platformFee)),
                const Divider(height: 20),
                Row(
                  children: [
                    Text('Net Earning', style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    AmountText(amount: booking.netEarning, fontSize: 20, color: AppColors.success),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomActions(booking: booking),
    );
  }

  Widget _kv(BuildContext context, String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(k, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(child: Text(v, style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GanagasevaCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _BottomActions extends ConsumerWidget {
  final Booking booking;
  const _BottomActions({required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(bookingRepositoryProvider.notifier);
    final status = booking.status;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: const Border(top: BorderSide(color: AppColors.border)),
        ),
        child: switch (status) {
          BookingStatus.pending => Row(
              children: [
                Expanded(
                  child: GanagasevaOutlinedButton(
                    label: 'Reject',
                    color: AppColors.error,
                    onPressed: () async {
                      await repo.updateStatus(booking.id, BookingStatus.rejected);
                      if (context.mounted) context.pop();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GanagasevaButton(
                    label: 'Accept',
                    onPressed: () async {
                      await repo.updateStatus(booking.id, BookingStatus.accepted);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Booking accepted')),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          BookingStatus.accepted || BookingStatus.upcoming => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GanagasevaButton(
                  label: 'Start Puja',
                  icon: Icons.play_arrow_rounded,
                  onPressed: () => repo.updateStatus(booking.id, BookingStatus.inProgress),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GanagasevaOutlinedButton(
                        label: 'Reschedule',
                        onPressed: () => context.push('/bookings/${booking.id}/reschedule'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GanagasevaOutlinedButton(
                        label: 'Cancel',
                        color: AppColors.error,
                        onPressed: () => context.push('/bookings/${booking.id}/cancel'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          BookingStatus.inProgress => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GanagasevaButton(
                  label: 'Record Video',
                  icon: Icons.videocam_rounded,
                  onPressed: () => context.push('/recording/${booking.id}'),
                ),
                const SizedBox(height: 8),
                GanagasevaOutlinedButton(
                  label: 'Mark Completed',
                  onPressed: () async {
                    await repo.updateStatus(booking.id, BookingStatus.completed);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Seva marked completed')),
                      );
                    }
                  },
                ),
              ],
            ),
          BookingStatus.completed => Row(
              children: [
                Expanded(
                  child: GanagasevaOutlinedButton(
                    label: 'View Video',
                    icon: Icons.play_circle_outline,
                    onPressed: () {
                      if (booking.videoId != null) {
                        context.push('/videos/${booking.videoId}');
                      } else {
                        context.push('/videos');
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GanagasevaButton(
                    label: 'Record Again',
                    icon: Icons.videocam_rounded,
                    onPressed: () => context.push('/recording/${booking.id}'),
                  ),
                ),
              ],
            ),
          _ => GanagasevaOutlinedButton(
              label: 'Back to Bookings',
              onPressed: () => context.pop(),
            ),
        },
      ),
    );
  }
}
