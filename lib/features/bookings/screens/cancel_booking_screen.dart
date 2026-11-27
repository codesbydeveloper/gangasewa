import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ganagaseva_button.dart';
import '../../../models/booking.dart';
import '../../../services/booking_repository.dart';

class CancelBookingScreen extends ConsumerStatefulWidget {
  final String bookingId;
  const CancelBookingScreen({super.key, required this.bookingId});

  @override
  ConsumerState<CancelBookingScreen> createState() => _CancelBookingScreenState();
}

class _CancelBookingScreenState extends ConsumerState<CancelBookingScreen> {
  String? _reason;
  final _other = TextEditingController();

  final _reasons = const [
    'Schedule conflict',
    'Devotee requested cancellation',
    'Unable to travel',
    'Health reasons',
    'Other',
  ];

  @override
  void dispose() {
    _other.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(bookingRepositoryProvider.notifier).byId(widget.bookingId);

    return Scaffold(
      appBar: AppBar(title: const Text('Cancel Booking')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Cancel ${booking?.bookingNumber ?? ''}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Please share a reason. The devotee may be notified.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          ..._reasons.map(
            (r) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                _reason == r ? Icons.radio_button_checked : Icons.radio_button_off,
                color: _reason == r ? AppColors.primary : AppColors.textMuted,
              ),
              title: Text(r),
              onTap: () => setState(() => _reason = r),
            ),
          ),
          if (_reason == 'Other') ...[
            const SizedBox(height: 8),
            TextField(
              controller: _other,
              decoration: const InputDecoration(labelText: 'Please specify'),
              maxLines: 3,
            ),
          ],
          const SizedBox(height: 28),
          GanagasevaButton(
            label: 'Confirm Cancellation',
            backgroundColor: AppColors.error,
            useGradient: false,
            onPressed: _reason == null
                ? null
                : () async {
                    await ref
                        .read(bookingRepositoryProvider.notifier)
                        .updateStatus(widget.bookingId, BookingStatus.cancelled);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Booking cancelled')),
                      );
                      context.go('/bookings');
                    }
                  },
          ),
        ],
      ),
    );
  }
}
