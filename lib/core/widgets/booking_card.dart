import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/booking.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import 'amount_text.dart';
import 'ganagaseva_card.dart';
import 'status_badge.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onTap;
  final bool compact;

  const BookingCard({
    super.key,
    required this.booking,
    this.onTap,
    this.compact = false,
  });

  IconData get _icon => switch (booking.pujaType.toLowerCase()) {
        final t when t.contains('temple') => Icons.temple_hindu_outlined,
        final t when t.contains('online') => Icons.videocam_outlined,
        final t when t.contains('jaap') => Icons.self_improvement_outlined,
        _ => Icons.local_fire_department_outlined,
      };

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'booking_${booking.id}',
      child: Material(
        color: Colors.transparent,
        child: GanagasevaCard(
          onTap: onTap,
          padding: EdgeInsets.all(compact ? 14 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: compact ? 44 : 52,
                    height: compact ? 44 : 52,
                    decoration: BoxDecoration(
                      color: AppColors.softBeige,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Icon(_icon, color: AppColors.primary, size: compact ? 22 : 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.pujaName,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          booking.devotee.name,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  StatusBadge.booking(booking.status, compact: true),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  _meta(context, Icons.calendar_today_outlined, Formatters.dayDate(booking.scheduledAt)),
                  _meta(context, Icons.access_time, Formatters.time(booking.scheduledAt)),
                  _meta(context, Icons.location_on_outlined, booking.location),
                ],
              ),
              if (!compact) ...[
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      booking.bookingNumber,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const Spacer(),
                    AmountText(
                      amount: booking.amount,
                      fontSize: 16,
                      color: AppColors.darkBrown,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _meta(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 140),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
