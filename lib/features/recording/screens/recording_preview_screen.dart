import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/ganagaseva_button.dart';
import '../../../models/video_recording.dart';
import '../../../services/booking_repository.dart';
import '../../../services/video_repository.dart';

class RecordingPreviewScreen extends ConsumerStatefulWidget {
  final String bookingId;
  final String bookingNumber;
  final String? path;

  const RecordingPreviewScreen({
    super.key,
    required this.bookingId,
    required this.bookingNumber,
    this.path,
  });

  @override
  ConsumerState<RecordingPreviewScreen> createState() => _RecordingPreviewScreenState();
}

class _RecordingPreviewScreenState extends ConsumerState<RecordingPreviewScreen> {
  VideoPlayerController? _player;
  bool _ready = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    if (widget.path == null) {
      setState(() => _ready = true);
      return;
    }
    try {
      final file = File(widget.path!);
      if (await file.exists()) {
        _player = VideoPlayerController.file(file);
        await _player!.initialize();
        await _player!.setLooping(true);
      }
    } catch (_) {}
    if (mounted) setState(() => _ready = true);
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    final player = _player;
    if (player == null || !player.value.isInitialized) return;
    setState(() {
      player.value.isPlaying ? player.pause() : player.play();
    });
  }

  Future<VideoRecording> _saveLocal() async {
    final booking = ref.read(bookingRepositoryProvider.notifier).byId(widget.bookingId);
    final video = VideoRecording(
      id: const Uuid().v4(),
      bookingId: widget.bookingId,
      bookingNumber: widget.bookingNumber,
      pujaName: booking?.pujaName ?? 'Puja Recording',
      devoteeName: booking?.devotee.name ?? 'Devotee',
      localPath: widget.path,
      duration: _player?.value.duration ?? const Duration(minutes: 1, seconds: 12),
      recordedAt: DateTime.now(),
      uploadStatus: VideoUploadStatus.local,
      isPrivate: true,
    );
    await ref.read(videoRepositoryProvider.notifier).saveLocal(video);
    return video;
  }

  @override
  Widget build(BuildContext context) {
    final hasPlayer = _player != null && _player!.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: AppColors.white,
        title: Text(widget.bookingNumber),
      ),
      body: Column(
        children: [
          Expanded(
            child: !_ready
                ? const Center(child: CircularProgressIndicator(color: AppColors.sacredGold))
                : hasPlayer
                    ? GestureDetector(
                        onTap: _togglePlay,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Center(
                              child: AspectRatio(
                                aspectRatio: _player!.value.aspectRatio,
                                child: VideoPlayer(_player!),
                              ),
                            ),
                            if (!_player!.value.isPlaying)
                              const Icon(Icons.play_circle_fill, size: 72, color: AppColors.white),
                          ],
                        ),
                      )
                    : Container(
                        color: AppColors.darkBrown,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.movie_creation_outlined,
                                size: 72,
                                color: AppColors.sacredGold.withValues(alpha: 0.8),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Video Preview Ready',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: AppColors.white,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Private recording • ${widget.bookingNumber}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.warmCream,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
          ),
          SafeArea(
            child: Container(
              color: AppColors.darkBg,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GanagasevaOutlinedButton(
                          label: 'Retake',
                          color: AppColors.white,
                          onPressed: _saving ? null : () => context.pop(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GanagasevaOutlinedButton(
                          label: hasPlayer && _player!.value.isPlaying ? 'Pause' : 'Play',
                          icon: hasPlayer && _player!.value.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: AppColors.white,
                          onPressed: hasPlayer ? _togglePlay : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GanagasevaButton(
                    label: 'Save',
                    isLoading: _saving,
                    onPressed: () async {
                      setState(() => _saving = true);
                      final video = await _saveLocal();
                      if (!context.mounted) return;
                      setState(() => _saving = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Saved offline — Upload when online')),
                      );
                      context.push('/videos/${video.id}');
                    },
                  ),
                  const SizedBox(height: 12),
                  GanagasevaOutlinedButton(
                    label: 'Upload Now',
                    icon: Icons.cloud_upload_outlined,
                    color: AppColors.white,
                    onPressed: _saving
                        ? null
                        : () async {
                            setState(() => _saving = true);
                            final video = await _saveLocal();
                            if (!context.mounted) return;
                            setState(() => _saving = false);
                            context.push('/upload-progress/${video.id}');
                          },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
