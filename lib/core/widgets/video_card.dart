import 'package:flutter/material.dart';
import '../../models/video_recording.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import 'ganagaseva_card.dart';

class VideoCard extends StatelessWidget {
  final VideoRecording video;
  final VoidCallback? onTap;

  const VideoCard({super.key, required this.video, this.onTap});

  String get _statusLabel => switch (video.uploadStatus) {
        VideoUploadStatus.local => 'Saved offline',
        VideoUploadStatus.preparing => 'Preparing',
        VideoUploadStatus.uploading => 'Uploading',
        VideoUploadStatus.processing => 'Processing',
        VideoUploadStatus.uploaded => 'Uploaded',
        VideoUploadStatus.failed => 'Upload failed',
      };

  Color get _statusColor => switch (video.uploadStatus) {
        VideoUploadStatus.uploaded => AppColors.success,
        VideoUploadStatus.failed => AppColors.error,
        VideoUploadStatus.local => AppColors.sacredGold,
        _ => AppColors.info,
      };

  @override
  Widget build(BuildContext context) {
    return GanagasevaCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'video_${video.id}',
            child: Container(
              height: 140,
              width: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                gradient: LinearGradient(
                  colors: [AppColors.darkBrown, AppColors.deepMaroon],
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.play_circle_fill_rounded,
                      size: 56,
                      color: AppColors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  if (video.isPrivate)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_outline, size: 12, color: AppColors.white),
                            SizedBox(width: 4),
                            Text(
                              'Private',
                              style: TextStyle(color: AppColors.white, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        Formatters.duration(video.duration),
                        style: const TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(video.pujaName, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '${video.devoteeName} • ${video.bookingNumber}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      Formatters.date(video.recordedAt),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const Spacer(),
                    Text(
                      _statusLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: _statusColor,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
