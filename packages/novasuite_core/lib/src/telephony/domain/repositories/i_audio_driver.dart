import 'dart:typed_data';

abstract class IAudioDriver {
  bool openAudioDevice();
  void playG711RtpPayload(Uint8List payload);
  void startMicrophoneCapture(void Function(Uint8List micFrame) onMicFrame);
  void stopMicrophoneCapture();
  void playPstnRingbackTone();
  void stopPstnRingbackTone();
  void closeAudioDevice();
}
