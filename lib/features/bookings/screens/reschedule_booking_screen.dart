import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/ganagaseva_button.dart';
import '../../../services/booking_repository.dart';

class RescheduleBookingScreen extends ConsumerStatefulWidget {
  final String bookingId;
  const RescheduleBookingScreen({super.key, required this.bookingId});

  @override
  ConsumerState<RescheduleBookingScreen> createState() =>
      _RescheduleBookingScreenState();
}

class _RescheduleBookingScreenState extends ConsumerState<RescheduleBookingScreen> {
  DateTime? _date;
  TimeOfDay? _time;

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(bookingRepositoryProvider.notifier).byId(widget.bookingId);
    _date ??= booking?.scheduledAt;
    _time ??= booking == null
        ? null
        : TimeOfDay(hour: booking.scheduledAt.hour, minute: booking.scheduledAt.minute);

    return Scaffold(
      appBar: AppBar(title: const Text('Reschedule Booking')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking?.bookingNumber ?? '',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Select a new date and time for this seva.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined),
              title: const Text('New Date'),
              subtitle: Text(_date == null ? 'Select date' : Formatters.date(_date!)),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  initialDate: _date ?? DateTime.now().add(const Duration(days: 1)),
                );
                if (d != null) setState(() => _date = d);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time),
              title: const Text('New Time'),
              subtitle: Text(_time?.format(context) ?? 'Select time'),
              onTap: () async {
                final t = await showTimePicker(
                  context: context,
                  initialTime: _time ?? const TimeOfDay(hour: 10, minute: 0),
                );
                if (t != null) setState(() => _time = t);
              },
            ),
            const Spacer(),
            GanagasevaButton(
              label: 'Confirm Reschedule',
              onPressed: _date == null || _time == null
                  ? null
                  : () async {
                      final dt = DateTime(
                        _date!.year,
                        _date!.month,
                        _date!.day,
                        _time!.hour,
                        _time!.minute,
                      );
                      await ref
                          .read(bookingRepositoryProvider.notifier)
                          .reschedule(widget.bookingId, dt);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Booking rescheduled')),
                        );
                        context.pop();
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
