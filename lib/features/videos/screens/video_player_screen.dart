import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../services/video_repository.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final String videoId;
  const VideoPlayerScreen({super.key, required this.videoId});

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _muted = false;
  double _speed = 1.0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final video = ref.read(videoRepositoryProvider.notifier).byId(widget.videoId);
    try {
      if (video?.localPath != null && File(video!.localPath!).existsSync()) {
        _controller = VideoPlayerController.file(File(video.localPath!));
      } else {
        // Demo network sample for uploaded videos without local file
        _controller = VideoPlayerController.networkUrl(
          Uri.parse('https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
        );
      }
      await _controller!.initialize();
      await _controller!.play();
    } catch (_) {
      _controller = null;
    }
    if (mounted) setState(() => _ready = true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final video = ref.watch(videoRepositoryProvider.notifier).byId(widget.videoId);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: AppColors.white,
        title: Text(video?.pujaName ?? 'Player'),
      ),
      body: !_ready
          ? const Center(child: CircularProgressIndicator(color: AppColors.sacredGold))
          : _controller == null || !_controller!.value.isInitialized
              ? Center(
                  child: Text(
                    'Unable to load video.\nPrivate recording placeholder.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.white),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              VideoPlayer(_controller!),
                              IconButton(
                                iconSize: 64,
                                onPressed: () {
                                  setState(() {
                                    _controller!.value.isPlaying
                                        ? _controller!.pause()
                                        : _controller!.play();
                                  });
                                },
                                icon: Icon(
                                  _controller!.value.isPlaying
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_filled,
                                  color: AppColors.white.withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    VideoProgressIndicator(
                      _controller!,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: AppColors.primary,
                        bufferedColor: AppColors.sacredGold,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: Row(
                        children: [
                          ValueListenableBuilder(
                            valueListenable: _controller!,
                            builder: (_, value, _) => Text(
                              '${Formatters.duration(value.position)} / ${Formatters.duration(value.duration)}',
                              style: const TextStyle(color: AppColors.white, fontSize: 12),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              _muted = !_muted;
                              _controller!.setVolume(_muted ? 0 : 1);
                              setState(() {});
                            },
                            icon: Icon(_muted ? Icons.volume_off : Icons.volume_up, color: AppColors.white),
                          ),
                          TextButton(
                            onPressed: () {
                              final speeds = [0.75, 1.0, 1.25, 1.5];
                              final i = speeds.indexOf(_speed);
                              _speed = speeds[(i + 1) % speeds.length];
                              _controller!.setPlaybackSpeed(_speed);
                              setState(() {});
                            },
                            child: Text('${_speed}x', style: const TextStyle(color: AppColors.white)),
                          ),
                          IconButton(
                            onPressed: () {
                              SystemChrome.setPreferredOrientations([
                                DeviceOrientation.landscapeLeft,
                                DeviceOrientation.landscapeRight,
                              ]);
                            },
                            icon: const Icon(Icons.fullscreen, color: AppColors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
