enum VideoUploadStatus { local, preparing, uploading, processing, uploaded, failed }

class VideoRecording {
  final String id;
  final String bookingId;
  final String bookingNumber;
  final String pujaName;
  final String devoteeName;
  final String? thumbnailUrl;
  final String? localPath;
  final String? remoteUrl;
  final Duration duration;
  final DateTime recordedAt;
  final VideoUploadStatus uploadStatus;
  final double uploadProgress;
  final bool isPrivate;

  const VideoRecording({
    required this.id,
    required this.bookingId,
    required this.bookingNumber,
    required this.pujaName,
    required this.devoteeName,
    this.thumbnailUrl,
    this.localPath,
    this.remoteUrl,
    required this.duration,
    required this.recordedAt,
    this.uploadStatus = VideoUploadStatus.local,
    this.uploadProgress = 0,
    this.isPrivate = true,
  });

  VideoRecording copyWith({
    String? id,
    String? bookingId,
    String? bookingNumber,
    String? pujaName,
    String? devoteeName,
    String? thumbnailUrl,
    String? localPath,
    String? remoteUrl,
    Duration? duration,
    DateTime? recordedAt,
    VideoUploadStatus? uploadStatus,
    double? uploadProgress,
    bool? isPrivate,
  }) {
    return VideoRecording(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      bookingNumber: bookingNumber ?? this.bookingNumber,
      pujaName: pujaName ?? this.pujaName,
      devoteeName: devoteeName ?? this.devoteeName,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      localPath: localPath ?? this.localPath,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      duration: duration ?? this.duration,
      recordedAt: recordedAt ?? this.recordedAt,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }
}
