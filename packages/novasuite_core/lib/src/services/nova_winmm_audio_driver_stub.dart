import 'dart:typed_data';

/// Cross-platform stub for NovaWinmmAudioDriver (Web / Mobile)
class NovaWinmmAudioDriver {
  static final NovaWinmmAudioDriver _instance = NovaWinmmAudioDriver._internal();
  factory NovaWinmmAudioDriver() => _instance;
  NovaWinmmAudioDriver._internal();

  static int pcm16ToULaw(int pcm16) => 0;
  static int uLawToPcm16(int uLaw) => 0;

  bool openAudioDevice() => false;
  void playG711RtpPayload(Uint8List rtpPacket) {}
  void playPstnRingbackTone() {}
  void startMicrophoneCapture(void Function(Uint8List g711Frame) onMicFrame) {}
  void closeAudioDevice() {}
}
