import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:math' as math;
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

// --- FFI Struct Definitions for Windows Multimedia API (winmm.dll) ---

base class WAVEFORMATEX extends Struct {
  @Uint16()
  external int wFormatTag;

  @Uint16()
  external int nChannels;

  @Uint32()
  external int nSamplesPerSec;

  @Uint32()
  external int nAvgBytesPerSec;

  @Uint16()
  external int nBlockAlign;

  @Uint16()
  external int wBitsPerSample;

  @Uint16()
  external int cbSize;
}

base class WAVEHDR extends Struct {
  external Pointer<Int8> lpData;

  @Uint32()
  external int dwBufferLength;

  @Uint32()
  external int dwBytesRecorded;

  @IntPtr()
  external int dwUser;

  @Uint32()
  external int dwFlags;

  @Uint32()
  external int dwLoops;

  external Pointer<WAVEHDR> lpNext;

  @IntPtr()
  external int reserved;
}

// --- Native C Function Signatures ---

typedef NativeWaveOutOpen = Int32 Function(
  Pointer<IntPtr> phwo,
  Uint32 uDeviceID,
  Pointer<WAVEFORMATEX> pwfx,
  IntPtr dwCallback,
  IntPtr dwInstance,
  Uint32 fdwOpen,
);

typedef DartWaveOutOpen = int Function(
  Pointer<IntPtr> phwo,
  int uDeviceID,
  Pointer<WAVEFORMATEX> pwfx,
  int dwCallback,
  int dwInstance,
  int fdwOpen,
);

typedef NativeWaveOutPrepareHeader = Int32 Function(
  IntPtr hwo,
  Pointer<WAVEHDR> pwh,
  Uint32 cbwh,
);

typedef DartWaveOutPrepareHeader = int Function(
  int hwo,
  Pointer<WAVEHDR> pwh,
  int cbwh,
);

typedef NativeWaveOutWrite = Int32 Function(
  IntPtr hwo,
  Pointer<WAVEHDR> pwh,
  Uint32 cbwh,
);

typedef DartWaveOutWrite = int Function(
  int hwo,
  Pointer<WAVEHDR> pwh,
  int cbwh,
);

typedef NativeWaveOutReset = Int32 Function(IntPtr hwo);
typedef DartWaveOutReset = int Function(int hwo);

typedef NativeWaveOutClose = Int32 Function(IntPtr hwo);
typedef DartWaveOutClose = int Function(int hwo);

typedef NativeWaveInOpen = Int32 Function(
  Pointer<IntPtr> phwi,
  Uint32 uDeviceID,
  Pointer<WAVEFORMATEX> pwfx,
  IntPtr dwCallback,
  IntPtr dwInstance,
  Uint32 fdwOpen,
);
typedef DartWaveInOpen = int Function(
  Pointer<IntPtr> phwi,
  int uDeviceID,
  Pointer<WAVEFORMATEX> pwfx,
  int dwCallback,
  int dwInstance,
  int fdwOpen,
);

typedef NativeWaveInPrepareHeader = Int32 Function(IntPtr hwi, Pointer<WAVEHDR> pwh, Uint32 cbwh);
typedef DartWaveInPrepareHeader = int Function(int hwi, Pointer<WAVEHDR> pwh, int cbwh);

typedef NativeWaveInUnprepareHeader = Int32 Function(IntPtr hwi, Pointer<WAVEHDR> pwh, Uint32 cbwh);
typedef DartWaveInUnprepareHeader = int Function(int hwi, Pointer<WAVEHDR> pwh, int cbwh);

typedef NativeWaveInAddBuffer = Int32 Function(IntPtr hwi, Pointer<WAVEHDR> pwh, Uint32 cbwh);
typedef DartWaveInAddBuffer = int Function(int hwi, Pointer<WAVEHDR> pwh, int cbwh);

typedef NativeWaveInStart = Int32 Function(IntPtr hwi);
typedef DartWaveInStart = int Function(int hwi);

typedef NativeWaveInStop = Int32 Function(IntPtr hwi);
typedef DartWaveInStop = int Function(int hwi);

typedef NativeWaveInReset = Int32 Function(IntPtr hwi);
typedef DartWaveInReset = int Function(int hwi);

typedef NativeWaveInClose = Int32 Function(IntPtr hwi);
typedef DartWaveInClose = int Function(int hwi);

/// Pure Native FFI Windows Sound Card Driver for G.711 RTP Audio Playback & Microphone Recording
class NovaWinmmAudioDriver {
  static final NovaWinmmAudioDriver _instance = NovaWinmmAudioDriver._internal();
  factory NovaWinmmAudioDriver() => _instance;

  NovaWinmmAudioDriver._internal();

  DynamicLibrary? _winmm;
  DartWaveOutOpen? _waveOutOpen;
  DartWaveOutPrepareHeader? _waveOutPrepareHeader;
  DartWaveOutWrite? _waveOutWrite;
  DartWaveOutReset? _waveOutReset;
  DartWaveOutClose? _waveOutClose;

  DartWaveInOpen? _waveInOpen;
  DartWaveInPrepareHeader? _waveInPrepareHeader;
  DartWaveInUnprepareHeader? _waveInUnprepareHeader;
  DartWaveInAddBuffer? _waveInAddBuffer;
  DartWaveInStart? _waveInStart;
  DartWaveInStop? _waveInStop;
  DartWaveInReset? _waveInReset;
  DartWaveInClose? _waveInClose;

  Pointer<IntPtr>? _hWaveOutPtr;
  Pointer<IntPtr>? _hWaveInPtr;
  int _hWaveOut = 0;
  int _hWaveIn = 0;
  bool _isOpen = false;
  bool _isMicRecording = false;

  Pointer<WAVEHDR>? _waveInHdr1;
  Pointer<WAVEHDR>? _waveInHdr2;
  Pointer<Int8>? _micBuffer1Ptr;
  Pointer<Int8>? _micBuffer2Ptr;
  Timer? _micPollingTimer;

  // Pre-allocated Circular Ring Buffer pool for crash-free RTP audio streaming
  static const int _numPlayBuffers = 16;
  final List<Pointer<WAVEHDR>> _playWaveHdrs = [];
  final List<Pointer<Int8>> _playPcmBuffers = [];
  final List<bool> _playBufferPrepared = [];
  int _playBufferIndex = 0;

  // G.711 u-law encoder (16-bit PCM to 8-bit G.711 u-law with anti-clipping gain control)
  static int pcm16ToULaw(int pcm16) {
    pcm16 = (pcm16 * 0.6).round().clamp(-32635, 32635);
    int sign = (pcm16 >> 8) & 0x80;
    if (sign != 0) pcm16 = -pcm16;
    if (pcm16 > 32635) pcm16 = 32635;
    pcm16 += 0x84;

    int exponent = 7;
    for (int expMask = 0x4000; (pcm16 & expMask) == 0 && exponent > 0; exponent--, expMask >>= 1) {}
    int mantissa = (pcm16 >> (exponent + 3)) & 0x0F;
    int uVal = ~(sign | (exponent << 4) | mantissa);
    return uVal & 0xFF;
  }

  // G.711 u-law to 16-bit PCM decompression table (ITU-T G.711 standard)
  static final List<int> _uLawToPcmTable = List<int>.generate(256, (i) {
    int mu = ~i;
    int sign = (mu & 0x80);
    int exponent = (mu >> 4) & 0x07;
    int mantissa = mu & 0x0F;
    int sample = ((mantissa << 3) + 132) << exponent;
    sample -= 132;
    return (sign != 0) ? -sample : sample;
  });

  static int uLawToPcm16(int uLaw) => _uLawToPcmTable[uLaw & 0xFF];

  /// Initializes Windows winmm.dll FFI bindings and opens 8000Hz 16-bit Mono WaveOut device
  bool openAudioDevice() {
    if (_isOpen && _hWaveOut != 0) return true;
    if (kIsWeb || !Platform.isWindows) return false;

    try {
      _winmm ??= DynamicLibrary.open('winmm.dll');
      _waveOutOpen ??= _winmm!.lookupFunction<NativeWaveOutOpen, DartWaveOutOpen>('waveOutOpen');
      _waveOutPrepareHeader ??= _winmm!.lookupFunction<NativeWaveOutPrepareHeader, DartWaveOutPrepareHeader>('waveOutPrepareHeader');
      _waveOutWrite ??= _winmm!.lookupFunction<NativeWaveOutWrite, DartWaveOutWrite>('waveOutWrite');
      _waveOutReset ??= _winmm!.lookupFunction<NativeWaveOutReset, DartWaveOutReset>('waveOutReset');
      _waveOutClose ??= _winmm!.lookupFunction<NativeWaveOutClose, DartWaveOutClose>('waveOutClose');

      _waveInOpen ??= _winmm!.lookupFunction<NativeWaveInOpen, DartWaveInOpen>('waveInOpen');
      _waveInPrepareHeader ??= _winmm!.lookupFunction<NativeWaveInPrepareHeader, DartWaveInPrepareHeader>('waveInPrepareHeader');
      _waveInUnprepareHeader ??= _winmm!.lookupFunction<NativeWaveInUnprepareHeader, DartWaveInUnprepareHeader>('waveInUnprepareHeader');
      _waveInAddBuffer ??= _winmm!.lookupFunction<NativeWaveInAddBuffer, DartWaveInAddBuffer>('waveInAddBuffer');
      _waveInStart ??= _winmm!.lookupFunction<NativeWaveInStart, DartWaveInStart>('waveInStart');
      _waveInStop ??= _winmm!.lookupFunction<NativeWaveInStop, DartWaveInStop>('waveInStop');
      _waveInReset ??= _winmm!.lookupFunction<NativeWaveInReset, DartWaveInReset>('waveInReset');
      _waveInClose ??= _winmm!.lookupFunction<NativeWaveInClose, DartWaveInClose>('waveInClose');

      _hWaveOutPtr = calloc<IntPtr>();

      final wfx = calloc<WAVEFORMATEX>();
      wfx.ref.wFormatTag = 1; // WAVE_FORMAT_PCM
      wfx.ref.nChannels = 1; // Mono
      wfx.ref.nSamplesPerSec = 8000; // 8kHz Telephony sample rate
      wfx.ref.wBitsPerSample = 16; // 16-bit PCM
      wfx.ref.nBlockAlign = 2; // 1 channel * 2 bytes
      wfx.ref.nAvgBytesPerSec = 8000 * 2; // 16,000 B/s
      wfx.ref.cbSize = 0;

      const WAVE_MAPPER = 0xFFFFFFFF;
      final result = _waveOutOpen!(_hWaveOutPtr!, WAVE_MAPPER, wfx, 0, 0, 0);
      calloc.free(wfx);

      if (result == 0) {
        _hWaveOut = _hWaveOutPtr!.value;
        _isOpen = true;

        if (_playWaveHdrs.isEmpty) {
          for (int i = 0; i < _numPlayBuffers; i++) {
            final pcmBuf = calloc<Int8>(3200);
            final waveHdr = calloc<WAVEHDR>();
            waveHdr.ref.lpData = pcmBuf;
            waveHdr.ref.dwBufferLength = 3200;
            waveHdr.ref.dwFlags = 0;

            _playPcmBuffers.add(pcmBuf);
            _playWaveHdrs.add(waveHdr);
            _playBufferPrepared.add(false);
          }
        }

        print('🎧 [Windows Native Audio] WaveOut WASAPI Audio Device Opened Successfully (Handle: $_hWaveOut)');
        return true;
      } else {
        print('⚠️ [Windows Native Audio] waveOutOpen returned error code: $result');
        return false;
      }
    } catch (e) {
      print('❌ [Windows Native Audio] FFI initialization failed: $e');
      return false;
    }
  }

  /// Plays incoming G.711 u-law RTP audio payload bytes directly to Windows Sound Card using Ring Buffer
  void playG711RtpPayload(Uint8List rtpPacket) {
    if (!_isOpen || _hWaveOut == 0) {
      if (!openAudioDevice()) return;
    }

    if (rtpPacket.length <= 12) return;
    final uLawPayload = rtpPacket.sublist(12);

    final numSamples = uLawPayload.length;
    final pcmBytesCount = numSamples * 2;

    _playBufferIndex = (_playBufferIndex + 1) % _numPlayBuffers;
    final waveHdr = _playWaveHdrs[_playBufferIndex];
    final pcmDataPtr = _playPcmBuffers[_playBufferIndex];

    if (_playBufferPrepared[_playBufferIndex]) {
      try {
        _winmm!.lookupFunction<NativeWaveOutPrepareHeader, DartWaveOutPrepareHeader>('waveOutUnprepareHeader')(_hWaveOut, waveHdr, sizeOf<WAVEHDR>());
      } catch (_) {}
      _playBufferPrepared[_playBufferIndex] = false;
    }

    final ByteData view = ByteData.view(pcmDataPtr.cast<Uint8>().asTypedList(pcmBytesCount).buffer);

    for (int i = 0; i < numSamples; i++) {
      final pcmSample = _uLawToPcmTable[uLawPayload[i]];
      view.setInt16(i * 2, pcmSample, Endian.little);
    }

    waveHdr.ref.dwBufferLength = pcmBytesCount;
    waveHdr.ref.dwFlags = 0;

    final prepResult = _waveOutPrepareHeader!(_hWaveOut, waveHdr, sizeOf<WAVEHDR>());
    if (prepResult == 0) {
      _playBufferPrepared[_playBufferIndex] = true;
      _waveOutWrite!(_hWaveOut, waveHdr, sizeOf<WAVEHDR>());
    }
  }

  /// Synthesizes pure 440Hz + 480Hz PSTN Ringback Tone PCM samples and plays directly to sound card
  void playPstnRingbackTone() {
    if (!_isOpen || _hWaveOut == 0) {
      if (!openAudioDevice()) return;
    }

    const int sampleRate = 8000;
    const int durationMs = 1500;
    final int numSamples = (sampleRate * durationMs) ~/ 1000;
    final int pcmBytesCount = numSamples * 2;

    _playBufferIndex = (_playBufferIndex + 1) % _numPlayBuffers;
    final waveHdr = _playWaveHdrs[_playBufferIndex];
    final pcmDataPtr = _playPcmBuffers[_playBufferIndex];

    if (_playBufferPrepared[_playBufferIndex]) {
      try {
        _winmm!.lookupFunction<NativeWaveOutPrepareHeader, DartWaveOutPrepareHeader>('waveOutUnprepareHeader')(_hWaveOut, waveHdr, sizeOf<WAVEHDR>());
      } catch (_) {}
      _playBufferPrepared[_playBufferIndex] = false;
    }

    final ByteData view = ByteData.view(pcmDataPtr.cast<Uint8>().asTypedList(pcmBytesCount).buffer);

    for (int i = 0; i < numSamples; i++) {
      final double t = i / sampleRate;
      final double sampleVal = (math.sin(2 * math.pi * 440 * t) + math.sin(2 * math.pi * 480 * t)) * 0.2;
      final int pcm16 = (sampleVal * 32767).clamp(-32768, 32767).toInt();
      view.setInt16(i * 2, pcm16, Endian.little);
    }

    waveHdr.ref.dwBufferLength = pcmBytesCount;
    waveHdr.ref.dwFlags = 0;

    final prepResult = _waveOutPrepareHeader!(_hWaveOut, waveHdr, sizeOf<WAVEHDR>());
    if (prepResult == 0) {
      _playBufferPrepared[_playBufferIndex] = true;
      _waveOutWrite!(_hWaveOut, waveHdr, sizeOf<WAVEHDR>());
    }
  }

  /// Starts capturing live microphone PCM audio and converting to 8000Hz G.711 u-law RTP payloads
  void startMicrophoneCapture(void Function(Uint8List g711Frame) onMicFrame) {
    if (!openAudioDevice() || _isMicRecording) return;

    try {
      _hWaveInPtr = calloc<IntPtr>();
      final wfx = calloc<WAVEFORMATEX>();
      wfx.ref.wFormatTag = 1; // WAVE_FORMAT_PCM
      wfx.ref.nChannels = 1; // Mono
      wfx.ref.nSamplesPerSec = 8000;
      wfx.ref.wBitsPerSample = 16;
      wfx.ref.nBlockAlign = 2;
      wfx.ref.nAvgBytesPerSec = 16000;
      wfx.ref.cbSize = 0;

      const WAVE_MAPPER = 0xFFFFFFFF;
      final res = _waveInOpen!(_hWaveInPtr!, WAVE_MAPPER, wfx, 0, 0, 0);
      calloc.free(wfx);

      if (res != 0) {
        print('⚠️ [Windows Native Audio] waveInOpen returned error: $res');
        return;
      }

      _hWaveIn = _hWaveInPtr!.value;
      const bufferSize = 320; // 160 samples = 20ms audio frame

      _micBuffer1Ptr = calloc<Int8>(bufferSize);
      _waveInHdr1 = calloc<WAVEHDR>();
      _waveInHdr1!.ref.lpData = _micBuffer1Ptr!;
      _waveInHdr1!.ref.dwBufferLength = bufferSize;
      _waveInHdr1!.ref.dwFlags = 0;

      _micBuffer2Ptr = calloc<Int8>(bufferSize);
      _waveInHdr2 = calloc<WAVEHDR>();
      _waveInHdr2!.ref.lpData = _micBuffer2Ptr!;
      _waveInHdr2!.ref.dwBufferLength = bufferSize;
      _waveInHdr2!.ref.dwFlags = 0;

      _waveInPrepareHeader!(_hWaveIn, _waveInHdr1!, sizeOf<WAVEHDR>());
      _waveInPrepareHeader!(_hWaveIn, _waveInHdr2!, sizeOf<WAVEHDR>());

      _waveInAddBuffer!(_hWaveIn, _waveInHdr1!, sizeOf<WAVEHDR>());
      _waveInAddBuffer!(_hWaveIn, _waveInHdr2!, sizeOf<WAVEHDR>());

      _waveInStart!(_hWaveIn);
      _isMicRecording = true;
      print('🎙️ [Windows Native Audio] Headset Microphone Active (8000Hz 16-bit Mono)');

      _micPollingTimer?.cancel();
      _micPollingTimer = Timer.periodic(const Duration(milliseconds: 20), (_) {
        if (!_isMicRecording || _hWaveIn == 0) {
          _micPollingTimer?.cancel();
          return;
        }

        final g711Frame = Uint8List(160);
        bool hasData = false;

        if (_waveInHdr1 != null && (_waveInHdr1!.ref.dwFlags & 0x01) != 0) { // WHDR_DONE
          final ByteData pcmView = ByteData.view(_micBuffer1Ptr!.cast<Uint8>().asTypedList(320).buffer);
          for (int i = 0; i < 160; i++) {
            final pcm16 = pcmView.getInt16(i * 2, Endian.little);
            g711Frame[i] = pcm16ToULaw(pcm16);
          }
          hasData = true;
          _waveInAddBuffer!(_hWaveIn, _waveInHdr1!, sizeOf<WAVEHDR>());
        } else if (_waveInHdr2 != null && (_waveInHdr2!.ref.dwFlags & 0x01) != 0) { // WHDR_DONE
          final ByteData pcmView = ByteData.view(_micBuffer2Ptr!.cast<Uint8>().asTypedList(320).buffer);
          for (int i = 0; i < 160; i++) {
            final pcm16 = pcmView.getInt16(i * 2, Endian.little);
            g711Frame[i] = pcm16ToULaw(pcm16);
          }
          hasData = true;
          _waveInAddBuffer!(_hWaveIn, _waveInHdr2!, sizeOf<WAVEHDR>());
        }

        if (hasData) {
          onMicFrame(g711Frame);
        }
      });
    } catch (e) {
      print('❌ [Windows Native Audio] Microphone initialization error: $e');
    }
  }

  /// Closes WaveOut and WaveIn audio device handles cleanly when call ends
  void closeAudioDevice() {
    _micPollingTimer?.cancel();
    _micPollingTimer = null;
    _isMicRecording = false;

    if (_hWaveIn != 0 && _waveInClose != null) {
      try {
        _waveInStop!(_hWaveIn);
        _waveInReset!(_hWaveIn);
        if (_waveInHdr1 != null) _waveInUnprepareHeader!(_hWaveIn, _waveInHdr1!, sizeOf<WAVEHDR>());
        if (_waveInHdr2 != null) _waveInUnprepareHeader!(_hWaveIn, _waveInHdr2!, sizeOf<WAVEHDR>());
        _waveInClose!(_hWaveIn);
        print('⏹️ [Windows Native Audio] WaveIn Microphone Device Closed.');
      } catch (_) {}
    }

    if (_micBuffer1Ptr != null) { calloc.free(_micBuffer1Ptr!); _micBuffer1Ptr = null; }
    if (_micBuffer2Ptr != null) { calloc.free(_micBuffer2Ptr!); _micBuffer2Ptr = null; }
    if (_waveInHdr1 != null) { calloc.free(_waveInHdr1!); _waveInHdr1 = null; }
    if (_waveInHdr2 != null) { calloc.free(_waveInHdr2!); _waveInHdr2 = null; }
    if (_hWaveInPtr != null) { calloc.free(_hWaveInPtr!); _hWaveInPtr = null; }
    _hWaveIn = 0;

    if (_isOpen && _hWaveOut != 0 && _waveOutClose != null) {
      try {
        if (_waveOutReset != null) {
          _waveOutReset!(_hWaveOut);
        }
        for (int i = 0; i < _playWaveHdrs.length; i++) {
          if (_playBufferPrepared[i]) {
            try {
              _winmm!.lookupFunction<NativeWaveOutPrepareHeader, DartWaveOutPrepareHeader>('waveOutUnprepareHeader')(_hWaveOut, _playWaveHdrs[i], sizeOf<WAVEHDR>());
            } catch (_) {}
            _playBufferPrepared[i] = false;
          }
        }
        _waveOutClose!(_hWaveOut);
        print('⏹️ [Windows Native Audio] WaveOut Audio Device Closed.');
      } catch (_) {}
    }

    if (_hWaveOutPtr != null) {
      calloc.free(_hWaveOutPtr!);
      _hWaveOutPtr = null;
    }
    _hWaveOut = 0;
    _isOpen = false;
  }
}
