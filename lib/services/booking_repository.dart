import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking.dart';
import 'mock_data.dart';

class BookingRepository extends StateNotifier<List<Booking>> {
  BookingRepository() : super([]) {
    _load();
  }

  Future<void> _load() async {
    await Future.delayed(const Duration(milliseconds: 400));
    state = List.from(MockData.bookings);
  }

  Future<void> refresh() async {
    await Future.delayed(const Duration(milliseconds: 500));
    state = List.from(MockData.bookings);
  }

  Booking? byId(String id) {
    try {
      return state.firstWhere((b) => b.id == id || b.bookingNumber == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateStatus(String id, BookingStatus status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    state = [
      for (final b in state)
        if (b.id == id) b.copyWith(status: status) else b,
    ];
  }

  Future<void> reschedule(String id, DateTime newDate) async {
    await Future.delayed(const Duration(milliseconds: 300));
    state = [
      for (final b in state)
        if (b.id == id)
          b.copyWith(scheduledAt: newDate, status: BookingStatus.upcoming)
        else
          b,
    ];
  }

  Future<Booking> create(Booking booking) async {
    await Future.delayed(const Duration(milliseconds: 500));
    state = [booking, ...state];
    return booking;
  }

  Future<void> update(Booking booking) async {
    await Future.delayed(const Duration(milliseconds: 400));
    state = [
      for (final b in state)
        if (b.id == booking.id) booking else b,
    ];
  }

  List<Booking> today() {
    final n = DateTime.now();
    return state.where((b) {
      return b.scheduledAt.year == n.year &&
          b.scheduledAt.month == n.month &&
          b.scheduledAt.day == n.day &&
          b.status != BookingStatus.cancelled &&
          b.status != BookingStatus.rejected;
    }).toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  List<Booking> upcoming() {
    return state
        .where((b) =>
            b.scheduledAt.isAfter(DateTime.now()) &&
            (b.status == BookingStatus.upcoming ||
                b.status == BookingStatus.accepted ||
                b.status == BookingStatus.pending))
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
  }

  List<Booking> filter({BookingStatus? status, String query = ''}) {
    var list = state;
    if (status != null) {
      list = list.where((b) => b.status == status).toList();
    }
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      list = list
          .where((b) =>
              b.pujaName.toLowerCase().contains(q) ||
              b.devotee.name.toLowerCase().contains(q) ||
              b.bookingNumber.toLowerCase().contains(q) ||
              b.location.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }
}

final bookingRepositoryProvider =
    StateNotifierProvider<BookingRepository, List<Booking>>((ref) {
  return BookingRepository();
});
