import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/ganagaseva_button.dart';
import '../../../core/widgets/ganagaseva_card.dart';
import '../../../models/video_recording.dart';
import '../../../services/video_repository.dart';

class VideoDetailScreen extends ConsumerWidget {
  final String videoId;
  const VideoDetailScreen({super.key, required this.videoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final video = ref.watch(videoRepositoryProvider.notifier).byId(videoId);
    if (video == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Video')),
        body: const Center(child: Text('Video not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await ConfirmDialog.show(
                context,
                title: 'Delete recording?',
                message: 'This private recording will be removed from your library.',
                confirmLabel: 'Delete',
                isDestructive: true,
              );
              if (ok == true) {
                await ref.read(videoRepositoryProvider.notifier).delete(videoId);
                if (context.mounted) context.pop();
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GestureDetector(
            onTap: () => context.push('/videos/$videoId/player'),
            child: Hero(
              tag: 'video_${video.id}',
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [AppColors.darkBrown, AppColors.deepMaroon],
                  ),
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(Icons.play_circle_fill_rounded, size: 72, color: AppColors.white),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.lock, size: 12, color: AppColors.white),
                            SizedBox(width: 4),
                            Text('Private recording',
                                style: TextStyle(color: AppColors.white, fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GanagasevaCard(
            child: Column(
              children: [
                _row(context, 'Puja', video.pujaName),
                _row(context, 'Devotee', video.devoteeName),
                _row(context, 'Booking', video.bookingNumber),
                _row(context, 'Recorded', Formatters.dateTime(video.recordedAt)),
                _row(context, 'Duration', Formatters.duration(video.duration)),
                _row(context, 'Status', video.uploadStatus.name),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (video.uploadStatus == VideoUploadStatus.local ||
              video.uploadStatus == VideoUploadStatus.failed)
            GanagasevaButton(
              label: 'Upload',
              icon: Icons.cloud_upload_outlined,
              onPressed: () => context.push('/upload-progress/${video.id}'),
            ),
          if (video.uploadStatus == VideoUploadStatus.local) ...[
            const SizedBox(height: 8),
            Text(
              'Saved offline — Upload when online',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.sacredGold),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GanagasevaOutlinedButton(
                  label: 'Share',
                  icon: Icons.share_outlined,
                  onPressed: () => Share.share(
                    'Private Ganagaseva recording ${video.bookingNumber} — available in-app only.',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GanagasevaOutlinedButton(
                  label: 'Play',
                  icon: Icons.play_arrow_rounded,
                  onPressed: () => context.push('/videos/$videoId/player'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String k, String v) {
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
