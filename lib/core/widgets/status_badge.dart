import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.compact = false,
  });

  factory StatusBadge.booking(BookingStatus status, {bool compact = false}) {
    return StatusBadge(
      label: _label(status),
      color: _color(status),
      compact: compact,
    );
  }

  static String _label(BookingStatus s) => switch (s) {
        BookingStatus.pending => 'Pending',
        BookingStatus.accepted => 'Accepted',
        BookingStatus.upcoming => 'Upcoming',
        BookingStatus.inProgress => 'In Progress',
        BookingStatus.completed => 'Completed',
        BookingStatus.cancelled => 'Cancelled',
        BookingStatus.rejected => 'Rejected',
      };

  static Color _color(BookingStatus s) => switch (s) {
        BookingStatus.pending => AppColors.statusPending,
        BookingStatus.accepted => AppColors.statusAccepted,
        BookingStatus.upcoming => AppColors.statusUpcoming,
        BookingStatus.inProgress => AppColors.statusInProgress,
        BookingStatus.completed => AppColors.statusCompleted,
        BookingStatus.cancelled => AppColors.statusCancelled,
        BookingStatus.rejected => AppColors.statusRejected,
      };

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 10 : 11,
            ),
      ),
    );
  }
}
