class TimeSlot {
  final String id;
  final String label;
  final int hour;
  final int minute;
  final bool isCustom;

  const TimeSlot({
    required this.id,
    required this.label,
    required this.hour,
    required this.minute,
    this.isCustom = false,
  });

  static const List<TimeSlot> defaults = [
    TimeSlot(id: '06', label: '06:00 AM', hour: 6, minute: 0),
    TimeSlot(id: '08', label: '08:00 AM', hour: 8, minute: 0),
    TimeSlot(id: '10', label: '10:00 AM', hour: 10, minute: 0),
    TimeSlot(id: '12', label: '12:00 PM', hour: 12, minute: 0),
    TimeSlot(id: '16', label: '04:00 PM', hour: 16, minute: 0),
    TimeSlot(id: '18', label: '06:00 PM', hour: 18, minute: 0),
    TimeSlot(id: '20', label: '08:00 PM', hour: 20, minute: 0),
  ];
}

class AvailabilityConfig {
  final Set<int> availableWeekdays; // 1=Mon ... 7=Sun
  final Set<String> selectedSlotIds;
  final Set<DateTime> blockedDates;
  final int maxBookingsPerDay;

  const AvailabilityConfig({
    this.availableWeekdays = const {1, 2, 3, 4, 5, 6},
    this.selectedSlotIds = const {'06', '08', '10', '16', '18'},
    this.blockedDates = const {},
    this.maxBookingsPerDay = 4,
  });

  AvailabilityConfig copyWith({
    Set<int>? availableWeekdays,
    Set<String>? selectedSlotIds,
    Set<DateTime>? blockedDates,
    int? maxBookingsPerDay,
  }) {
    return AvailabilityConfig(
      availableWeekdays: availableWeekdays ?? this.availableWeekdays,
      selectedSlotIds: selectedSlotIds ?? this.selectedSlotIds,
      blockedDates: blockedDates ?? this.blockedDates,
      maxBookingsPerDay: maxBookingsPerDay ?? this.maxBookingsPerDay,
    );
  }
}
