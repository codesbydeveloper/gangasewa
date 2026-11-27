import 'dart:io';

import 'package:ffmpeg_kit_flutter_new_min/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_min/return_code.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class VideoComposeException implements Exception {
  VideoComposeException(this.message, {this.segmentPaths = const []});

  final String message;
  final List<String> segmentPaths;

  @override
  String toString() => message;
}

class VideoComposeResult {
  const VideoComposeResult({
    required this.outputPath,
    required this.merged,
    this.segmentPaths = const [],
  });

  final String outputPath;
  final bool merged;
  final List<String> segmentPaths;
}

/// Combines camera segments into one playable MP4 in app documents.
class VideoComposeService {
  static const _width = 720;
  static const _height = 1280;
  static const _fps = 30;

  Future<Directory> recordingsDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/recordings');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<VideoComposeResult> compose(List<String> segments) async {
    final existing = <String>[];
    for (final path in segments) {
      final file = File(path);
      if (await file.exists() && await file.length() > 0) {
        existing.add(path);
      }
    }

    if (existing.isEmpty) {
      throw VideoComposeException('No recorded video segments were found.');
    }

    final outDir = await recordingsDir();
    final outputPath = '${outDir.path}/seva_${const Uuid().v4()}.mp4';

    if (existing.length == 1) {
      await File(existing.first).copy(outputPath);
      await _deleteSegments(existing);
      return VideoComposeResult(outputPath: outputPath, merged: false);
    }

    if (kIsWeb) {
      throw VideoComposeException(
        'Merging camera segments is not supported on web.',
        segmentPaths: existing,
      );
    }

    var session = await FFmpegKit.executeWithArguments(
      _buildConcatArgs(existing, outputPath, withAudio: true),
    );
    var code = await session.getReturnCode();

    if (!ReturnCode.isSuccess(code)) {
      debugPrint('FFmpeg audio merge failed: ${await session.getLogsAsString()}');
      session = await FFmpegKit.executeWithArguments(
        _buildConcatArgs(existing, outputPath, withAudio: false),
      );
      code = await session.getReturnCode();
    }

    if (!ReturnCode.isSuccess(code)) {
      debugPrint('FFmpeg merge failed: ${await session.getLogsAsString()}');
      throw VideoComposeException(
        'Could not combine camera clips into one video. Your recorded clips were kept.',
        segmentPaths: existing,
      );
    }

    final out = File(outputPath);
    if (!await out.exists() || await out.length() == 0) {
      throw VideoComposeException(
        'The merged video file was empty. Your recorded clips were kept.',
        segmentPaths: existing,
      );
    }

    await _deleteSegments(existing);
    return VideoComposeResult(
      outputPath: outputPath,
      merged: true,
      segmentPaths: existing,
    );
  }

  List<String> _buildConcatArgs(
    List<String> inputs,
    String outputPath, {
    required bool withAudio,
  }) {
    final args = <String>['-y', '-hide_banner', '-loglevel', 'error'];
    for (final path in inputs) {
      args.addAll(['-i', path]);
    }

    final filters = StringBuffer();
    for (var i = 0; i < inputs.length; i++) {
      filters.write(
        '[$i:v]scale=$_width:$_height:force_original_aspect_ratio=decrease,'
        'pad=$_width:$_height:(ow-iw)/2:(oh-ih)/2:black,setsar=1,fps=$_fps,'
        'format=yuv420p[v$i];',
      );
      if (withAudio) {
        filters.write(
          '[$i:a]aformat=sample_fmts=fltp:sample_rates=44100:channel_layouts=stereo,'
          'aresample=44100[a$i];',
        );
      }
    }

    for (var i = 0; i < inputs.length; i++) {
      filters.write(withAudio ? '[v$i][a$i]' : '[v$i]');
    }
    filters.write(
      withAudio
          ? 'concat=n=${inputs.length}:v=1:a=1[outv][outa]'
          : 'concat=n=${inputs.length}:v=1:a=0[outv]',
    );

    args.addAll(['-filter_complex', filters.toString(), '-map', '[outv]']);
    if (withAudio) {
      args.addAll(['-map', '[outa]', '-c:a', 'aac', '-b:a', '128k', '-ar', '44100', '-ac', '2']);
    }
    args.addAll([
      '-c:v',
      'mpeg4',
      '-q:v',
      '5',
      '-r',
      '$_fps',
      '-movflags',
      '+faststart',
      outputPath,
    ]);
    return args;
  }

  Future<void> _deleteSegments(List<String> paths) async {
    for (final path in paths) {
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
  }
}
