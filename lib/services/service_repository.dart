import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/availability.dart';
import '../models/puja_service.dart';
import 'mock_data.dart';

class ServiceRepository extends StateNotifier<List<PujaService>> {
  ServiceRepository() : super(List.from(MockData.services));

  Future<void> upsert(PujaService service) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final exists = state.any((s) => s.id == service.id);
    if (exists) {
      state = [for (final s in state) if (s.id == service.id) service else s];
    } else {
      state = [service, ...state];
    }
  }

  Future<void> toggle(String id) async {
    state = [
      for (final s in state)
        if (s.id == id) s.copyWith(isActive: !s.isActive) else s,
    ];
  }

  Future<void> delete(String id) async {
    state = state.where((s) => s.id != id).toList();
  }

  PujaService? byId(String id) {
    try {
      return state.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }
}

class AvailabilityRepository extends StateNotifier<AvailabilityConfig> {
  AvailabilityRepository() : super(const AvailabilityConfig());

  void update(AvailabilityConfig config) => state = config;
}

final serviceRepositoryProvider =
    StateNotifierProvider<ServiceRepository, List<PujaService>>((ref) {
  return ServiceRepository();
});

final availabilityRepositoryProvider =
    StateNotifierProvider<AvailabilityRepository, AvailabilityConfig>((ref) {
  return AvailabilityRepository();
});
