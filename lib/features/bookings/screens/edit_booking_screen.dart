import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/ganagaseva_button.dart';
import '../../../services/booking_repository.dart';

class EditBookingScreen extends ConsumerStatefulWidget {
  final String bookingId;
  const EditBookingScreen({super.key, required this.bookingId});

  @override
  ConsumerState<EditBookingScreen> createState() => _EditBookingScreenState();
}

class _EditBookingScreenState extends ConsumerState<EditBookingScreen> {
  late TextEditingController _puja;
  late TextEditingController _location;
  late TextEditingController _amount;
  late TextEditingController _instructions;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final b = ref.read(bookingRepositoryProvider.notifier).byId(widget.bookingId);
      if (b == null) return;
      _puja = TextEditingController(text: b.pujaName);
      _location = TextEditingController(text: b.location);
      _amount = TextEditingController(text: b.amount.toStringAsFixed(0));
      _instructions = TextEditingController(text: b.specialInstructions ?? '');
      setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final booking = ref.read(bookingRepositoryProvider.notifier).byId(widget.bookingId)!;

    return Scaffold(
      appBar: AppBar(title: Text('Edit ${booking.bookingNumber}')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: _puja, decoration: const InputDecoration(labelText: 'Puja Name')),
          const SizedBox(height: 12),
          TextField(controller: _location, decoration: const InputDecoration(labelText: 'Location')),
          const SizedBox(height: 12),
          TextField(
            controller: _amount,
            decoration: const InputDecoration(labelText: 'Amount', prefixText: '₹ '),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _instructions,
            decoration: const InputDecoration(labelText: 'Special Instructions'),
            maxLines: 3,
          ),
          const SizedBox(height: 28),
          GanagasevaButton(
            label: 'Save Changes',
            onPressed: () async {
              final amount = double.tryParse(_amount.text) ?? booking.amount;
              await ref.read(bookingRepositoryProvider.notifier).update(
                    booking.copyWith(
                      pujaName: _puja.text.trim(),
                      location: _location.text.trim(),
                      amount: amount,
                      platformFee: amount * 0.05,
                      specialInstructions: _instructions.text.trim(),
                    ),
                  );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking updated')),
                );
                context.pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
