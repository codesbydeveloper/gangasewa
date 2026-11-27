import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/video_recording.dart';
import 'mock_data.dart';

class VideoRepository extends StateNotifier<List<VideoRecording>> {
  VideoRepository() : super(List.from(MockData.videos));

  VideoRecording? byId(String id) {
    try {
      return state.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<VideoRecording> saveLocal(VideoRecording video) async {
    await Future.delayed(const Duration(milliseconds: 300));
    state = [video, ...state.where((v) => v.id != video.id)];
    return video;
  }

  Stream<VideoRecording> upload(String id) async* {
    var video = byId(id);
    if (video == null) return;

    video = video.copyWith(uploadStatus: VideoUploadStatus.preparing, uploadProgress: 0.05);
    _upsert(video);
    yield video;
    await Future.delayed(const Duration(milliseconds: 600));

    for (final p in [0.25, 0.5, 0.75, 0.9]) {
      video = video!.copyWith(
        uploadStatus: VideoUploadStatus.uploading,
        uploadProgress: p,
      );
      _upsert(video);
      yield video;
      await Future.delayed(const Duration(milliseconds: 700));
    }

    video = video!.copyWith(
      uploadStatus: VideoUploadStatus.processing,
      uploadProgress: 0.95,
    );
    _upsert(video);
    yield video;
    await Future.delayed(const Duration(milliseconds: 800));

    video = video.copyWith(
      uploadStatus: VideoUploadStatus.uploaded,
      uploadProgress: 1,
    );
    _upsert(video);
    yield video;
  }

  Future<void> markFailed(String id) async {
    final v = byId(id);
    if (v == null) return;
    _upsert(v.copyWith(uploadStatus: VideoUploadStatus.failed));
  }

  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    state = state.where((v) => v.id != id).toList();
  }

  void _upsert(VideoRecording video) {
    state = [
      for (final v in state)
        if (v.id == video.id) video else v,
    ];
    if (!state.any((v) => v.id == video.id)) {
      state = [video, ...state];
    }
  }
}

final videoRepositoryProvider =
    StateNotifierProvider<VideoRepository, List<VideoRecording>>((ref) {
  return VideoRepository();
});
