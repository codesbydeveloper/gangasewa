import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_search_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/video_card.dart';
import '../../../models/video_recording.dart';
import '../../../services/video_repository.dart';

class MyVideosScreen extends ConsumerStatefulWidget {
  const MyVideosScreen({super.key});

  @override
  ConsumerState<MyVideosScreen> createState() => _MyVideosScreenState();
}

class _MyVideosScreenState extends ConsumerState<MyVideosScreen> {
  int _tab = 0;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final videos = ref.watch(videoRepositoryProvider);
    final filtered = videos.where((v) {
      final matchQuery = _query.isEmpty ||
          v.pujaName.toLowerCase().contains(_query.toLowerCase()) ||
          v.devoteeName.toLowerCase().contains(_query.toLowerCase()) ||
          v.bookingNumber.toLowerCase().contains(_query.toLowerCase());
      final matchTab = switch (_tab) {
        1 => v.uploadStatus == VideoUploadStatus.uploading ||
            v.uploadStatus == VideoUploadStatus.preparing ||
            v.uploadStatus == VideoUploadStatus.processing,
        2 => v.uploadStatus == VideoUploadStatus.uploaded,
        3 => v.uploadStatus == VideoUploadStatus.local ||
            v.uploadStatus == VideoUploadStatus.failed,
        _ => true,
      };
      return matchQuery && matchTab;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Videos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: AppSearchBar(
              hint: 'Search recordings',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                for (final (i, label) in ['All', 'Uploading', 'Uploaded', 'Offline'].indexed)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AppFilterChip(
                      label: label,
                      selected: _tab == i,
                      onSelected: () => setState(() => _tab = i),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? const EmptyState(
                    icon: Icons.video_library_outlined,
                    title: 'No puja recordings yet',
                    message: 'Your completed seva recordings will appear here.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => VideoCard(
                      video: filtered[i],
                      onTap: () => context.push('/videos/${filtered[i].id}'),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
