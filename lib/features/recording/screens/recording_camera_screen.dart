import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/ganagaseva_button.dart';
import '../../../services/booking_repository.dart';
import '../services/video_compose_service.dart';

class RecordingCameraScreen extends ConsumerStatefulWidget {
  final String? bookingId;
  const RecordingCameraScreen({super.key, this.bookingId});

  @override
  ConsumerState<RecordingCameraScreen> createState() => _RecordingCameraScreenState();
}

class _RecordingCameraScreenState extends ConsumerState<RecordingCameraScreen>
    with WidgetsBindingObserver {
  final _composer = VideoComposeService();

  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _cameraIndex = 0;
  bool _flashOn = false;
  bool _sessionRecording = false;
  bool _paused = false;
  bool _permissionDenied = false;
  bool _initializing = true;
  bool _switching = false;
  bool _processing = false;
  bool _busy = false;
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  String? _bookingNumber;
  String? _error;
  final List<String> _segments = [];
  Future<void>? _op;

  bool get _ready =>
      _controller != null && _controller!.value.isInitialized && !_initializing;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _resolveBooking();
    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _handleAppBackground();
    } else if (state == AppLifecycleState.resumed) {
      if (_cameras.isNotEmpty && _controller == null) {
        _setupController(_cameras[_cameraIndex], resumeSession: _sessionRecording);
      }
    }
  }

  Future<void> _handleAppBackground() async {
    if (_sessionRecording && _controller != null) {
      try {
        await _stopCurrentSegment();
      } catch (_) {}
    }
    await _releaseCamera(keepSession: _sessionRecording);
  }

  void _resolveBooking() {
    final id = widget.bookingId;
    if (id == null) return;
    final b = ref.read(bookingRepositoryProvider.notifier).byId(id);
    _bookingNumber = b?.bookingNumber;
  }

  Future<void> _exclusive(Future<void> Function() action) async {
    while (_op != null) {
      try {
        await _op;
      } catch (_) {}
    }
    late final Future<void> future;
    future = action();
    _op = future;
    try {
      await future;
    } finally {
      if (identical(_op, future)) {
        _op = null;
      }
    }
  }

  Future<void> _initCamera() async {
    final cam = await Permission.camera.request();
    final mic = await Permission.microphone.request();
    if (!cam.isGranted || !mic.isGranted) {
      if (!mounted) return;
      setState(() {
        _permissionDenied = true;
        _initializing = false;
      });
      return;
    }
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _initializing = false;
            _error = 'No camera was found on this device.';
          });
        }
        return;
      }
      _cameraIndex = _cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.back);
      if (_cameraIndex < 0) _cameraIndex = 0;
      await _setupController(_cameras[_cameraIndex]);
    } catch (e) {
      if (mounted) {
        setState(() {
          _initializing = false;
          _error = 'Could not start the camera. Please try again.';
        });
      }
    }
  }

  Future<void> _releaseCamera({bool keepSession = false}) async {
    final old = _controller;
    _controller = null;
    if (mounted) {
      setState(() {
        _initializing = true;
        _paused = false;
        _flashOn = false;
        if (!keepSession) _sessionRecording = false;
      });
    }
    try {
      if (old != null) {
        if (old.value.isRecordingVideo) {
          try {
            await old.stopVideoRecording();
          } catch (_) {}
        }
        await old.dispose();
      }
    } catch (_) {}
  }

  Future<void> _setupController(
    CameraDescription camera, {
    bool resumeSession = false,
  }) async {
    await _exclusive(() async {
      final old = _controller;
      _controller = null;
      if (mounted) {
        setState(() {
          _initializing = true;
          _flashOn = false;
          _error = null;
        });
      }

      await Future<void>.delayed(const Duration(milliseconds: 60));

      try {
        if (old != null) {
          if (old.value.isRecordingVideo) {
            try {
              await old.stopVideoRecording();
            } catch (_) {}
          }
          await old.dispose();
        }
      } catch (_) {}

      if (!mounted) return;

      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      try {
        await controller.initialize();
        try {
          await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
        } catch (_) {}
        try {
          await controller.setFlashMode(FlashMode.off);
        } catch (_) {}
        if (!mounted) {
          await controller.dispose();
          return;
        }
        setState(() {
          _controller = controller;
          _initializing = false;
        });
        if (resumeSession && _sessionRecording) {
          await Future<void>.delayed(const Duration(milliseconds: 250));
          await _startSegment(controller);
        }
      } catch (_) {
        try {
          await controller.dispose();
        } catch (_) {}
        if (mounted) {
          setState(() {
            _controller = null;
            _initializing = false;
            _error = 'Camera could not be initialized. Please retry.';
          });
        }
      }
    });
  }

  Future<void> _startSegment(CameraController controller) async {
    if (!controller.value.isInitialized || controller.value.isRecordingVideo) return;
    await controller.startVideoRecording();
    if (mounted) setState(() => _paused = false);
  }

  Future<void> _stopCurrentSegment() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized || !c.value.isRecordingVideo) return;
    final file = await c.stopVideoRecording();
    final path = file.path;
    if (path.isNotEmpty && await File(path).exists() && await File(path).length() > 0) {
      _segments.add(path);
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _processing || _busy) return;
    HapticFeedback.mediumImpact();
    if (mounted) setState(() => _switching = true);

    try {
      if (_sessionRecording && _controller?.value.isRecordingVideo == true) {
        await _stopCurrentSegment();
      }

      _cameraIndex = (_cameraIndex + 1) % _cameras.length;
      await _setupController(
        _cameras[_cameraIndex],
        resumeSession: _sessionRecording,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not switch camera. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _switching = false);
    }
  }

  Future<void> _toggleFlash() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized || _busy) return;
    try {
      final next = !_flashOn;
      await c.setFlashMode(next ? FlashMode.torch : FlashMode.off);
      if (mounted) setState(() => _flashOn = next);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Flash is not available on this camera.')),
      );
    }
  }

  Future<void> _toggleRecord() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized) {
      _startDemoRecording();
      return;
    }
    if (_busy || _initializing || _processing || _switching) return;
    HapticFeedback.heavyImpact();

    try {
      if (_sessionRecording) {
        if (_paused) {
          await c.resumeVideoRecording();
          _paused = false;
          _startTimer();
          if (mounted) setState(() {});
          return;
        }
        await _finishSession();
      } else {
        _busy = true;
        _segments.clear();
        await _startSegment(c);
        _busy = false;
        if (!mounted) return;
        setState(() {
          _sessionRecording = true;
          _paused = false;
          _elapsed = Duration.zero;
        });
        _startTimer();
      }
    } catch (_) {
      _busy = false;
      if (mounted) {
        setState(() {
          _sessionRecording = false;
          _paused = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not start or stop recording. Please try again.')),
        );
      }
    }
  }

  Future<void> _finishSession() async {
    _timer?.cancel();
    if (mounted) {
      setState(() {
        _processing = true;
        _sessionRecording = false;
        _paused = false;
      });
    }

    try {
      await _stopCurrentSegment();
    } catch (_) {}

    if (_segments.isEmpty) {
      if (mounted) {
        setState(() => _processing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nothing was recorded. Please try again.')),
        );
      }
      return;
    }

    try {
      final result = await _composer.compose(_segments);
      if (!mounted) return;
      setState(() => _processing = false);
      _goPreview(result.outputPath);
    } on VideoComposeException catch (e) {
      if (!mounted) return;
      setState(() => _processing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
      if (e.segmentPaths.isNotEmpty) {
        _goPreview(e.segmentPaths.first);
      } else if (_segments.isNotEmpty) {
        _goPreview(_segments.first);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _processing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not create the final video. Your clips were kept.'),
        ),
      );
      if (_segments.isNotEmpty) _goPreview(_segments.first);
    }
  }

  void _startDemoRecording() {
    if (_sessionRecording) {
      _timer?.cancel();
      setState(() => _sessionRecording = false);
      _goPreview(null);
      return;
    }
    setState(() {
      _sessionRecording = true;
      _elapsed = Duration.zero;
    });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_paused && _sessionRecording && mounted) {
        setState(() => _elapsed += const Duration(seconds: 1));
      }
    });
  }

  Future<void> _pause() async {
    final c = _controller;
    if (!_sessionRecording || c == null || !c.value.isInitialized || _busy || _switching) {
      return;
    }
    try {
      if (_paused) {
        await c.resumeVideoRecording();
        _paused = false;
        _startTimer();
      } else {
        await c.pauseVideoRecording();
        _paused = true;
        _timer?.cancel();
      }
      if (mounted) setState(() {});
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pause is not supported on this device.')),
      );
    }
  }

  Future<void> _pickGallery() async {
    if (_sessionRecording) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stop recording before opening the gallery.')),
      );
      return;
    }
    final file = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (file != null && mounted) _goPreview(file.path);
  }

  void _goPreview(String? path) {
    final bookings = ref.read(bookingRepositoryProvider);
    final booking = widget.bookingId != null
        ? ref.read(bookingRepositoryProvider.notifier).byId(widget.bookingId!)
        : (bookings.isNotEmpty ? bookings.first : null);

    context.push('/record-preview', extra: {
      'bookingId': booking?.id ?? widget.bookingId ?? '',
      'bookingNumber': booking?.bookingNumber ?? _bookingNumber ?? 'GS-NEW',
      'path': path,
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    final controller = _controller;
    _controller = null;
    controller?.dispose();
    super.dispose();
  }

  Widget _preview() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.sacredGold),
        ),
      );
    }

    final size = controller.value.previewSize;
    if (size == null) {
      return CameraPreview(controller);
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: size.height,
        height: size.width,
        child: CameraPreview(controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _bookingNumber ?? 'Record Puja';

    if (_permissionDenied) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.videocam_off_outlined, size: 64, color: AppColors.primary),
              const SizedBox(height: 16),
              Text('Camera permission needed', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'Please allow camera and microphone access to record puja videos. Recording can still work offline once permitted.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              GanagasevaButton(label: 'Open Settings', onPressed: openAppSettings),
              const SizedBox(height: 12),
              GanagasevaOutlinedButton(
                label: 'Continue with Demo Preview',
                onPressed: () => _goPreview(null),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_ready)
            KeyedSubtree(
              key: ValueKey('camera_$_cameraIndex'),
              child: _preview(),
            )
          else
            Container(
              color: Colors.black,
              child: Center(
                child: _initializing
                    ? const CircularProgressIndicator(color: AppColors.sacredGold)
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.videocam_rounded,
                            size: 72,
                            color: AppColors.sacredGold.withValues(alpha: 0.7),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _error ?? 'Camera preview unavailable\nTap record for demo flow',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.warmCream,
                                ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: _cameras.isEmpty
                                ? _initCamera
                                : () => _setupController(_cameras[_cameraIndex]),
                            child: const Text('Retry camera'),
                          ),
                        ],
                      ),
              ),
            ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _processing
                            ? null
                            : () {
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go('/home');
                                }
                              },
                        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
                      ),
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.white,
                              ),
                        ),
                      ),
                      if (_sessionRecording)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'REC ${Formatters.duration(_elapsed)}',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ControlButton(
                        icon: Icons.photo_library_outlined,
                        label: 'Gallery',
                        onTap: (_sessionRecording || _processing) ? null : _pickGallery,
                      ),
                      _ControlButton(
                        icon: Icons.cameraswitch_outlined,
                        label: 'Switch',
                        onTap: (_busy || _processing || _switching || _cameras.length < 2)
                            ? null
                            : _switchCamera,
                      ),
                      GestureDetector(
                        onTap: _processing ? null : _toggleRecord,
                        child: Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.white, width: 4),
                          ),
                          padding: const EdgeInsets.all(5),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(_sessionRecording ? 12 : 40),
                            ),
                          ),
                        ),
                      ),
                      _ControlButton(
                        icon: _flashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                        label: 'Flash',
                        onTap: _ready && !_processing ? _toggleFlash : null,
                      ),
                      _ControlButton(
                        icon: _paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                        label: _paused ? 'Resume' : 'Pause',
                        onTap: _sessionRecording && !_processing ? _pause : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_switching)
            ColoredBox(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.sacredGold),
                    const SizedBox(height: 16),
                    Text(
                      'Switching camera…',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.white,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          if (_processing)
            ColoredBox(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.sacredGold),
                    const SizedBox(height: 16),
                    Text(
                      'Creating your video…',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.white,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Combining camera clips into one file',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.warmCream,
                          ),
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

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ControlButton({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 56,
        child: Column(
          children: [
            Icon(icon, color: onTap == null ? Colors.white38 : AppColors.white, size: 26),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: onTap == null ? Colors.white38 : AppColors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
