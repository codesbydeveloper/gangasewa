import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/ganagaseva_button.dart';
import '../../../models/booking.dart';
import '../../../models/devotee.dart';
import '../../../services/booking_repository.dart';

class CreateBookingScreen extends ConsumerStatefulWidget {
  const CreateBookingScreen({super.key});

  @override
  ConsumerState<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends ConsumerState<CreateBookingScreen> {
  int _step = 0;
  final _formKeys = List.generate(4, (_) => GlobalKey<FormState>());

  final _devoteeName = TextEditingController();
  final _mobile = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();
  final _gotra = TextEditingController();
  final _nakshatra = TextEditingController();
  final _rashi = TextEditingController();
  final _family = TextEditingController();
  final _pujaName = TextEditingController(text: 'Satyanarayan Katha');
  final _pujaType = TextEditingController(text: 'Home Puja');
  final _duration = TextEditingController(text: '120');
  final _amount = TextEditingController(text: '5500');
  final _instructions = TextEditingController();
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [
      _devoteeName, _mobile, _email, _address, _gotra, _nakshatra, _rashi,
      _family, _pujaName, _pujaType, _duration, _amount, _instructions,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    final scheduled = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
    final amount = double.tryParse(_amount.text) ?? 0;
    final booking = Booking(
      id: const Uuid().v4(),
      bookingNumber: 'GS-${10000 + DateTime.now().millisecond}',
      pujaName: _pujaName.text.trim(),
      pujaType: _pujaType.text.trim(),
      devotee: Devotee(
        id: const Uuid().v4(),
        name: _devoteeName.text.trim(),
        phone: _mobile.text.trim(),
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
        address: _address.text.trim(),
        gotra: _gotra.text.trim(),
        nakshatra: _nakshatra.text.trim(),
        rashi: _rashi.text.trim(),
        familyMembers: _family.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
      ),
      scheduledAt: scheduled,
      duration: Duration(minutes: int.tryParse(_duration.text) ?? 60),
      location: _address.text.trim().isEmpty ? 'Home' : _address.text.trim(),
      amount: amount,
      platformFee: amount * 0.05,
      status: BookingStatus.upcoming,
      specialInstructions: _instructions.text.trim().isEmpty ? null : _instructions.text.trim(),
      createdAt: DateTime.now(),
    );
    await ref.read(bookingRepositoryProvider.notifier).create(booking);
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking created successfully')),
      );
      context.go('/bookings/${booking.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Booking')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: _StepIndicator(step: _step, total: 5),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: SingleChildScrollView(
                key: ValueKey(_step),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: switch (_step) {
                  0 => Form(
                      key: _formKeys[0],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Devotee Information', style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 16),
                          TextFormField(controller: _devoteeName, decoration: const InputDecoration(labelText: 'Devotee Name *'), validator: _req),
                          const SizedBox(height: 12),
                          TextFormField(controller: _mobile, decoration: const InputDecoration(labelText: 'Mobile *'), keyboardType: TextInputType.phone, validator: (v) => (v == null || v.length < 10) ? 'Enter valid mobile' : null),
                          const SizedBox(height: 12),
                          TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
                          const SizedBox(height: 12),
                          TextFormField(controller: _address, decoration: const InputDecoration(labelText: 'Address *'), validator: _req, maxLines: 2),
                          const SizedBox(height: 12),
                          TextFormField(controller: _gotra, decoration: const InputDecoration(labelText: 'Gotra')),
                          const SizedBox(height: 12),
                          TextFormField(controller: _nakshatra, decoration: const InputDecoration(labelText: 'Nakshatra')),
                          const SizedBox(height: 12),
                          TextFormField(controller: _rashi, decoration: const InputDecoration(labelText: 'Rashi')),
                          const SizedBox(height: 12),
                          TextFormField(controller: _family, decoration: const InputDecoration(labelText: 'Family Members', hintText: 'Comma separated')),
                        ],
                      ),
                    ),
                  1 => Form(
                      key: _formKeys[1],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Puja Information', style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 16),
                          TextFormField(controller: _pujaName, decoration: const InputDecoration(labelText: 'Puja Name *'), validator: _req),
                          const SizedBox(height: 12),
                          TextFormField(controller: _pujaType, decoration: const InputDecoration(labelText: 'Puja Type *'), validator: _req),
                          const SizedBox(height: 12),
                          TextFormField(controller: _duration, decoration: const InputDecoration(labelText: 'Duration (minutes) *'), keyboardType: TextInputType.number, validator: _req),
                          const SizedBox(height: 12),
                          TextFormField(controller: _instructions, decoration: const InputDecoration(labelText: 'Special Instructions'), maxLines: 3),
                        ],
                      ),
                    ),
                  2 => Form(
                      key: _formKeys[2],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Schedule', style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 16),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Date'),
                            subtitle: Text(Formatters.date(_date)),
                            trailing: const Icon(Icons.calendar_today_outlined),
                            onTap: () async {
                              final d = await showDatePicker(
                                context: context,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                                initialDate: _date,
                              );
                              if (d != null) setState(() => _date = d);
                            },
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Time'),
                            subtitle: Text(_time.format(context)),
                            trailing: const Icon(Icons.access_time),
                            onTap: () async {
                              final t = await showTimePicker(context: context, initialTime: _time);
                              if (t != null) setState(() => _time = t);
                            },
                          ),
                        ],
                      ),
                    ),
                  3 => Form(
                      key: _formKeys[3],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Payment', style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _amount,
                            decoration: const InputDecoration(labelText: 'Service Amount (₹) *', prefixText: '₹ '),
                            keyboardType: TextInputType.number,
                            validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0 ? 'Enter amount' : null,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Platform fee (5%) will be calculated automatically.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  _ => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Confirmation', style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 16),
                        _confirmRow('Devotee', _devoteeName.text),
                        _confirmRow('Mobile', _mobile.text),
                        _confirmRow('Puja', _pujaName.text),
                        _confirmRow('Date', Formatters.date(_date)),
                        _confirmRow('Time', _time.format(context)),
                        _confirmRow('Amount', Formatters.currency(double.tryParse(_amount.text) ?? 0)),
                        _confirmRow('Location', _address.text),
                      ],
                    ),
                },
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: GanagasevaOutlinedButton(
                        label: 'Back',
                        onPressed: () => setState(() => _step--),
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: GanagasevaButton(
                      label: _step == 4 ? 'Create Booking' : 'Continue',
                      isLoading: _saving,
                      onPressed: () async {
                        if (_step < 4) {
                          if (_step <= 3 && !_formKeys[_step].currentState!.validate()) return;
                          setState(() => _step++);
                        } else {
                          await _submit();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _req(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;

  Widget _confirmRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(k, style: Theme.of(context).textTheme.bodySmall)),
          Expanded(child: Text(v, style: Theme.of(context).textTheme.titleSmall)),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int step;
  final int total;
  const _StepIndicator({required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final active = i <= step;
        return Expanded(
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: active ? AppColors.primary : AppColors.borderStrong,
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    color: active ? AppColors.white : AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (i < total - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: i < step ? AppColors.primary : AppColors.border,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
