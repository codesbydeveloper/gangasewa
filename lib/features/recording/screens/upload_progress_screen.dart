import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ganagaseva_button.dart';
import '../../../core/widgets/ganagaseva_card.dart';
import '../../../models/video_recording.dart';
import '../../../services/video_repository.dart';

class UploadProgressScreen extends ConsumerStatefulWidget {
  final String videoId;
  const UploadProgressScreen({super.key, required this.videoId});

  @override
  ConsumerState<UploadProgressScreen> createState() => _UploadProgressScreenState();
}

class _UploadProgressScreenState extends ConsumerState<UploadProgressScreen> {
  VideoRecording? _video;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    setState(() => _failed = false);
    await for (final v in ref.read(videoRepositoryProvider.notifier).upload(widget.videoId)) {
      if (!mounted) return;
      setState(() => _video = v);
      if (v.uploadStatus == VideoUploadStatus.uploaded) {
        await Future.delayed(const Duration(milliseconds: 400));
        if (mounted) context.go('/upload-success/${v.id}');
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final video = _video ?? ref.watch(videoRepositoryProvider.notifier).byId(widget.videoId);
    final progress = video?.uploadProgress ?? 0;
    final status = video?.uploadStatus ?? VideoUploadStatus.preparing;

    String statusLabel = switch (status) {
      VideoUploadStatus.preparing => 'Preparing',
      VideoUploadStatus.uploading => 'Uploading',
      VideoUploadStatus.processing => 'Processing',
      VideoUploadStatus.uploaded => 'Completed',
      VideoUploadStatus.failed => 'Upload failed',
      VideoUploadStatus.local => 'Saved locally',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Uploading Video')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GanagasevaCard(
              child: Column(
                children: [
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [AppColors.darkBrown, AppColors.deepMaroon],
                      ),
                    ),
                    child: const Icon(Icons.cloud_upload_rounded, size: 56, color: AppColors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(video?.pujaName ?? 'Puja Recording', style: Theme.of(context).textTheme.titleLarge),
                  Text(video?.bookingNumber ?? '', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(statusLabel, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              '${(progress * 100).round()}%',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: AppColors.border,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            _Stage(label: 'Preparing', done: progress >= 0.05),
            _Stage(label: 'Uploading', done: progress >= 0.25),
            _Stage(label: 'Processing', done: progress >= 0.95),
            _Stage(label: 'Completed', done: progress >= 1),
            const Spacer(),
            if (_failed || status == VideoUploadStatus.failed) ...[
              Text(
                'Upload failed. Your recording is safe on this device.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              GanagasevaButton(label: 'Retry', onPressed: _start),
              const SizedBox(height: 10),
              GanagasevaOutlinedButton(
                label: 'Save Locally',
                onPressed: () => context.go('/videos/${widget.videoId}'),
              ),
            ] else
              Text(
                'Please keep the app open while uploading.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            TextButton(
              onPressed: () async {
                await ref.read(videoRepositoryProvider.notifier).markFailed(widget.videoId);
                setState(() => _failed = true);
              },
              child: const Text('Simulate Failure (Demo)'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stage extends StatelessWidget {
  final String label;
  final bool done;
  const _Stage({required this.label, required this.done});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            color: done ? AppColors.success : AppColors.textMuted,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
