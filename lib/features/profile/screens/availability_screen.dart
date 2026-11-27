import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ganagaseva_button.dart';
import '../../../core/widgets/ganagaseva_card.dart';
import '../../../models/availability.dart';
import '../../../services/service_repository.dart';

class AvailabilityScreen extends ConsumerStatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  ConsumerState<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends ConsumerState<AvailabilityScreen> {
  late AvailabilityConfig _config;
  DateTime _focusedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _config = ref.read(availabilityRepositoryProvider);
  }

  @override
  Widget build(BuildContext context) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Scaffold(
      appBar: AppBar(title: const Text('Availability')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Available Days', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: List.generate(7, (i) {
              final day = i + 1;
              final selected = _config.availableWeekdays.contains(day);
              return FilterChip(
                label: Text(days[i]),
                selected: selected,
                onSelected: (_) {
                  final set = Set<int>.from(_config.availableWeekdays);
                  selected ? set.remove(day) : set.add(day);
                  setState(() => _config = _config.copyWith(availableWeekdays: set));
                },
              );
            }),
          ),
          const SizedBox(height: 24),
          Text('Time Slots', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TimeSlot.defaults.map((slot) {
              final selected = _config.selectedSlotIds.contains(slot.id);
              return FilterChip(
                label: Text(slot.label),
                selected: selected,
                onSelected: (_) {
                  final set = Set<String>.from(_config.selectedSlotIds);
                  selected ? set.remove(slot.id) : set.add(slot.id);
                  setState(() => _config = _config.copyWith(selectedSlotIds: set));
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('Calendar / Blocked Dates', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          GanagasevaCard(
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => setState(() {
                        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                      }),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Expanded(
                      child: Text(
                        '${_monthName(_focusedMonth.month)} ${_focusedMonth.year}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() {
                        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                      }),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _daysInMonth(_focusedMonth),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                  ),
                  itemBuilder: (_, i) {
                    final day = i + 1;
                    final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
                    final blocked = _config.blockedDates.any((d) =>
                        d.year == date.year && d.month == date.month && d.day == date.day);
                    return InkWell(
                      onTap: () {
                        final set = Set<DateTime>.from(_config.blockedDates);
                        if (blocked) {
                          set.removeWhere((d) =>
                              d.year == date.year && d.month == date.month && d.day == date.day);
                        } else {
                          set.add(date);
                        }
                        setState(() => _config = _config.copyWith(blockedDates: set));
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: blocked ? AppColors.error.withValues(alpha: 0.15) : AppColors.softBeige,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: blocked ? AppColors.error : AppColors.border,
                          ),
                        ),
                        child: Text(
                          '$day',
                          style: TextStyle(
                            color: blocked ? AppColors.error : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap a date to mark holiday / blocked',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Maximum bookings / day', style: Theme.of(context).textTheme.titleMedium),
          Slider(
            value: _config.maxBookingsPerDay.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            label: '${_config.maxBookingsPerDay}',
            activeColor: AppColors.primary,
            onChanged: (v) => setState(
              () => _config = _config.copyWith(maxBookingsPerDay: v.round()),
            ),
          ),
          const SizedBox(height: 16),
          GanagasevaButton(
            label: 'Save Availability',
            onPressed: () {
              ref.read(availabilityRepositoryProvider.notifier).update(_config);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Availability saved')),
              );
            },
          ),
        ],
      ),
    );
  }

  int _daysInMonth(DateTime m) => DateTime(m.year, m.month + 1, 0).day;

  String _monthName(int m) => const [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December',
      ][m - 1];
}
