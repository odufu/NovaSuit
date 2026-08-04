class CallRecording {
  final String recordingId;
  final String callId;
  final String localFilePath;
  final String? cloudUrl;
  final int durationSeconds;
  final int fileSizeBytes;
  final DateTime createdAt;

  const CallRecording({
    required this.recordingId,
    required this.callId,
    required this.localFilePath,
    this.cloudUrl,
    required this.durationSeconds,
    required this.fileSizeBytes,
    required this.createdAt,
  });

  CallRecording copyWith({
    String? cloudUrl,
    int? durationSeconds,
    int? fileSizeBytes,
  }) {
    return CallRecording(
      recordingId: recordingId,
      callId: callId,
      localFilePath: localFilePath,
      cloudUrl: cloudUrl ?? this.cloudUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recordingId': recordingId,
      'callId': callId,
      'localFilePath': localFilePath,
      'cloudUrl': cloudUrl,
      'durationSeconds': durationSeconds,
      'fileSizeBytes': fileSizeBytes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
