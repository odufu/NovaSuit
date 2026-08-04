import 'dart:typed_data';
import '../entities/call_recording.dart';

abstract class ICallRecorder {
  bool get isRecording;
  String? get activeLocalFilePath;

  Future<String> startRecording({
    required String callId,
    required String customerPhone,
  });

  void recordAgentMicrophoneFrame(Uint8List pcmOrULawBytes);
  void recordCustomerIncomingFrame(Uint8List pcmOrULawBytes);

  Future<CallRecording?> stopRecording({
    required int durationSeconds,
  });
}
