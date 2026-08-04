import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../../domain/entities/call_recording.dart';
import '../../domain/repositories/i_call_recorder.dart';
import '../../../services/nova_winmm_audio_driver.dart';

class WaveCallRecorder implements ICallRecorder {
  static final WaveCallRecorder _instance = WaveCallRecorder._internal();
  factory WaveCallRecorder() => _instance;
  WaveCallRecorder._internal();

  File? _activeFile;
  RandomAccessFile? _raf;
  bool _isRecording = false;
  int _totalPcmBytesWritten = 0;
  String? _currentCallId;
  DateTime? _startTime;

  @override
  bool get isRecording => _isRecording;

  @override
  String? get activeLocalFilePath => _activeFile?.path;

  @override
  Future<String> startRecording({
    required String callId,
    required String customerPhone,
  }) async {
    try {
      _currentCallId = callId;
      _startTime = DateTime.now();
      _totalPcmBytesWritten = 0;

      final recordingsDir = await _getRecordingsDirectory();
      final sanitizedPhone = customerPhone.replaceAll(RegExp(r'\D'), '');
      final fileName = 'REC_${DateTime.now().millisecondsSinceEpoch}_$sanitizedPhone.wav';
      _activeFile = File('${recordingsDir.path}/$fileName');

      _raf = await _activeFile!.open(mode: FileMode.write);
      
      // Write placeholder 44-byte WAV header (8000Hz, 16-bit, Mono PCM)
      final header = _buildWavHeader(dataLength: 0);
      await _raf!.writeFrom(header);

      _isRecording = true;
      print('🎙️ [Call Recorder] Started recording 2-way call audio to: ${_activeFile!.path}');
      return _activeFile!.path;
    } catch (e) {
      print('⚠️ [Call Recorder] Failed to initialize call recording file: $e');
      _isRecording = false;
      return '';
    }
  }

  @override
  void recordAgentMicrophoneFrame(Uint8List micULawFrame) {
    if (!_isRecording || _raf == null) return;
    try {
      final pcm16Bytes = _uLawToPcm16Bytes(micULawFrame);
      _raf!.writeFromSync(pcm16Bytes);
      _totalPcmBytesWritten += pcm16Bytes.length;
    } catch (_) {}
  }

  @override
  void recordCustomerIncomingFrame(Uint8List customerULawFrame) {
    if (!_isRecording || _raf == null) return;
    try {
      final pcm16Bytes = _uLawToPcm16Bytes(customerULawFrame);
      _raf!.writeFromSync(pcm16Bytes);
      _totalPcmBytesWritten += pcm16Bytes.length;
    } catch (_) {}
  }

  @override
  Future<CallRecording?> stopRecording({
    required int durationSeconds,
  }) async {
    if (!_isRecording || _raf == null || _activeFile == null) return null;

    try {
      _isRecording = false;

      // Update RIFF and Data sizes in WAV header
      final header = _buildWavHeader(dataLength: _totalPcmBytesWritten);
      await _raf!.setPosition(0);
      await _raf!.writeFrom(header);
      await _raf!.close();
      _raf = null;

      final fileLength = await _activeFile!.length();
      print('🎙️ [Call Recorder] Recording completed! File size: $fileLength bytes (${_activeFile!.path})');

      final recording = CallRecording(
        recordingId: 'rec_${DateTime.now().millisecondsSinceEpoch}',
        callId: _currentCallId ?? 'unknown_call',
        localFilePath: _activeFile!.path,
        durationSeconds: durationSeconds,
        fileSizeBytes: fileLength,
        createdAt: _startTime ?? DateTime.now(),
      );

      _activeFile = null;
      return recording;
    } catch (e) {
      print('⚠️ [Call Recorder] Error finalizing call recording file: $e');
      return null;
    }
  }

  Uint8List _uLawToPcm16Bytes(Uint8List uLawBytes) {
    final pcm16Data = ByteData(uLawBytes.length * 2);
    for (int i = 0; i < uLawBytes.length; i++) {
      int pcm16 = NovaWinmmAudioDriver.uLawToPcm16(uLawBytes[i]);
      pcm16Data.setInt16(i * 2, pcm16, Endian.little);
    }
    return pcm16Data.buffer.asUint8List();
  }

  Uint8List _buildWavHeader({required int dataLength}) {
    final header = ByteData(44);
    final totalLength = dataLength + 36;

    // RIFF header
    header.setUint8(0, 0x52); // R
    header.setUint8(1, 0x49); // I
    header.setUint8(2, 0x46); // F
    header.setUint8(3, 0x46); // F
    header.setUint32(4, totalLength, Endian.little);

    // WAVE
    header.setUint8(8, 0x57);  // W
    header.setUint8(9, 0x41);  // A
    header.setUint8(10, 0x56); // V
    header.setUint8(11, 0x45); // E

    // fmt chunk
    header.setUint8(12, 0x66); // f
    header.setUint8(13, 0x6D); // m
    header.setUint8(14, 0x74); // t
    header.setUint8(15, 0x20); // space
    header.setUint32(16, 16, Endian.little); // Chunk size 16
    header.setUint16(20, 1, Endian.little);  // Format 1 (PCM)
    header.setUint16(22, 1, Endian.little);  // Channels: 1 (Mono)
    header.setUint32(24, 8000, Endian.little); // Sample Rate: 8000Hz
    header.setUint32(28, 16000, Endian.little); // Byte Rate: 8000 * 2 = 16000
    header.setUint16(32, 2, Endian.little);  // Block Align: 2
    header.setUint16(34, 16, Endian.little); // Bits per sample: 16

    // data chunk
    header.setUint8(36, 0x64); // d
    header.setUint8(37, 0x61); // a
    header.setUint8(38, 0x74); // t
    header.setUint8(39, 0x61); // a
    header.setUint32(40, dataLength, Endian.little);

    return header.buffer.asUint8List();
  }

  Future<Directory> _getRecordingsDirectory() async {
    Directory dir;
    if (Platform.isWindows) {
      final appData = Platform.environment['LOCALAPPDATA'] ?? 'C:\\';
      dir = Directory('$appData\\NovaSuite\\Recordings');
    } else {
      dir = Directory('${Directory.systemTemp.path}/NovaSuiteRecordings');
    }
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }
}
