import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/booking_card.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../models/booking.dart';
import '../../../services/booking_repository.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _search = TextEditingController();
  String _query = '';
  BookingStatus? _filterStatus;
  String? _pujaType;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _tabs.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabs.dispose();
    _search.dispose();
    super.dispose();
  }

  List<Booking> _filtered(List<Booking> all) {
    BookingStatus? tabStatus;
    switch (_tabs.index) {
      case 1:
        tabStatus = BookingStatus.pending;
      case 2:
        tabStatus = BookingStatus.upcoming;
      case 3:
        tabStatus = BookingStatus.completed;
    }

    var list = ref.read(bookingRepositoryProvider.notifier).filter(
          status: tabStatus ?? _filterStatus,
          query: _query,
        );

    // For "Upcoming" tab also include accepted
    if (_tabs.index == 2) {
      list = all.where((b) {
        final matchQuery = _query.isEmpty ||
            b.pujaName.toLowerCase().contains(_query.toLowerCase()) ||
            b.devotee.name.toLowerCase().contains(_query.toLowerCase()) ||
            b.bookingNumber.toLowerCase().contains(_query.toLowerCase());
        final matchStatus = b.status == BookingStatus.upcoming ||
            b.status == BookingStatus.accepted ||
            b.status == BookingStatus.inProgress;
        return matchQuery && matchStatus;
      }).toList();
    }

    if (_pujaType != null) {
      list = list.where((b) => b.pujaType == _pujaType).toList();
    }
    return list;
  }

  void _showFilters() {
    PrimaryBottomSheet.show(
      context,
      title: 'Filter Bookings',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              AppFilterChip(
                label: 'Any',
                selected: _filterStatus == null,
                onSelected: () => setState(() => _filterStatus = null),
              ),
              ...BookingStatus.values.map(
                (s) => AppFilterChip(
                  label: s.name[0].toUpperCase() + s.name.substring(1),
                  selected: _filterStatus == s,
                  onSelected: () => setState(() => _filterStatus = s),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Puja Type', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final t in ['Home Puja', 'Temple Puja', 'Home Ceremony', 'Special Jaap'])
                AppFilterChip(
                  label: t,
                  selected: _pujaType == t,
                  onSelected: () => setState(() => _pujaType = _pujaType == t ? null : t),
                ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookings = ref.watch(bookingRepositoryProvider);
    final list = _filtered(bookings);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
        actions: [
          IconButton(
            onPressed: () => context.push('/bookings-create'),
            icon: const Icon(Icons.add_rounded),
            tooltip: 'New Booking',
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: AppSearchBar(
              controller: _search,
              hint: 'Search puja, devotee, booking ID',
              onChanged: (v) => setState(() => _query = v),
              onFilter: _showFilters,
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? EmptyState(
                    icon: Icons.event_busy_outlined,
                    title: 'No seva bookings yet',
                    message: 'Your upcoming seva requests will appear here.',
                    actionLabel: 'Create Booking',
                    onAction: () => context.push('/bookings-create'),
                  )
                : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () =>
                        ref.read(bookingRepositoryProvider.notifier).refresh(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => BookingCard(
                        booking: list[i],
                        onTap: () => context.push('/bookings/${list[i].id}'),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
