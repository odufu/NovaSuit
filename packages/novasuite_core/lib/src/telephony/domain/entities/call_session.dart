import 'call_direction.dart';
import 'call_recording.dart';

class CallSession {
  final String callId;
  final CallDirection direction;
  final String customerPhone;
  final String? customerName;
  final DateTime startTime;
  final DateTime? answerTime;
  final DateTime? endTime;
  final int durationSeconds;
  final String? providerReason;
  final CallRecording? recording;

  const CallSession({
    required this.callId,
    required this.direction,
    required this.customerPhone,
    this.customerName,
    required this.startTime,
    this.answerTime,
    this.endTime,
    required this.durationSeconds,
    this.providerReason,
    this.recording,
  });

  CallSession copyWith({
    DateTime? answerTime,
    DateTime? endTime,
    int? durationSeconds,
    String? providerReason,
    CallRecording? recording,
  }) {
    return CallSession(
      callId: callId,
      direction: direction,
      customerPhone: customerPhone,
      customerName: customerName,
      startTime: startTime,
      answerTime: answerTime ?? this.answerTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      providerReason: providerReason ?? this.providerReason,
      recording: recording ?? this.recording,
    );
  }
}
