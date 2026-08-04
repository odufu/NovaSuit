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

typedef NativeWaveOutClose = Int32 Function(IntPtr hwo);
typedef DartWaveOutClose = int Function(int hwo);

/// Pure Native FFI Windows Sound Card Driver for G.711 RTP Audio Playback
class NovaWinmmAudioDriver {
  static final NovaWinmmAudioDriver _instance = NovaWinmmAudioDriver._internal();
  factory NovaWinmmAudioDriver() => _instance;

  NovaWinmmAudioDriver._internal();

  DynamicLibrary? _winmm;
  DartWaveOutOpen? _waveOutOpen;
  DartWaveOutPrepareHeader? _waveOutPrepareHeader;
  DartWaveOutWrite? _waveOutWrite;
  DartWaveOutClose? _waveOutClose;

  Pointer<IntPtr>? _hWaveOutPtr;
  int _hWaveOut = 0;
  bool _isOpen = false;

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

  /// Initializes Windows winmm.dll FFI bindings and opens 8000Hz 16-bit Mono WaveOut device
  bool openAudioDevice() {
    if (_isOpen) return true;
    if (kIsWeb || !Platform.isWindows) return false;

    try {
      _winmm ??= DynamicLibrary.open('winmm.dll');
      _waveOutOpen ??= _winmm!.lookupFunction<NativeWaveOutOpen, DartWaveOutOpen>('waveOutOpen');
      _waveOutPrepareHeader ??= _winmm!.lookupFunction<NativeWaveOutPrepareHeader, DartWaveOutPrepareHeader>('waveOutPrepareHeader');
      _waveOutWrite ??= _winmm!.lookupFunction<NativeWaveOutWrite, DartWaveOutWrite>('waveOutWrite');
      _waveOutClose ??= _winmm!.lookupFunction<NativeWaveOutClose, DartWaveOutClose>('waveOutClose');

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

  /// Plays incoming G.711 u-law RTP audio payload bytes directly to Windows Sound Card
  void playG711RtpPayload(Uint8List rtpPacket) {
    if (!_isOpen || _hWaveOut == 0) {
      if (!openAudioDevice()) return;
    }

    // RTP Header is typically 12 bytes; audio payload follows
    if (rtpPacket.length <= 12) return;
    final uLawPayload = rtpPacket.sublist(12);

    final numSamples = uLawPayload.length;
    final pcmBytesCount = numSamples * 2;

    final pcmDataPtr = calloc<Int8>(pcmBytesCount);
    final ByteData view = ByteData.view(pcmDataPtr.cast<Uint8>().asTypedList(pcmBytesCount).buffer);

    for (int i = 0; i < numSamples; i++) {
      final pcmSample = _uLawToPcmTable[uLawPayload[i]];
      view.setInt16(i * 2, pcmSample, Endian.little);
    }

    final waveHdr = calloc<WAVEHDR>();
    waveHdr.ref.lpData = pcmDataPtr;
    waveHdr.ref.dwBufferLength = pcmBytesCount;
    waveHdr.ref.dwFlags = 0;

    final prepResult = _waveOutPrepareHeader!(_hWaveOut, waveHdr, sizeOf<WAVEHDR>());
    if (prepResult == 0) {
      _waveOutWrite!(_hWaveOut, waveHdr, sizeOf<WAVEHDR>());
    }

    // Schedule cleanup of memory pointers after buffer playback (~500ms)
    Future.delayed(const Duration(milliseconds: 500), () {
      try {
        calloc.free(pcmDataPtr);
        calloc.free(waveHdr);
      } catch (_) {}
    });
  }

  /// Synthesizes pure 440Hz + 480Hz PSTN Ringback Tone PCM samples and plays directly to sound card
  void playPstnRingbackTone() {
    if (!_isOpen || _hWaveOut == 0) {
      if (!openAudioDevice()) return;
    }

    const int sampleRate = 8000;
    const int durationMs = 1500; // 1.5 second ringback burst
    final int numSamples = (sampleRate * durationMs) ~/ 1000;
    final int pcmBytesCount = numSamples * 2;

    final pcmDataPtr = calloc<Int8>(pcmBytesCount);
    final ByteData view = ByteData.view(pcmDataPtr.cast<Uint8>().asTypedList(pcmBytesCount).buffer);

    for (int i = 0; i < numSamples; i++) {
      final double t = i / sampleRate;
      // 440Hz + 480Hz dual sine wave PSTN ringback tone
      final double sampleVal = (math.sin(2 * math.pi * 440 * t) + math.sin(2 * math.pi * 480 * t)) * 0.2;
      final int pcm16 = (sampleVal * 32767).clamp(-32768, 32767).toInt();
      view.setInt16(i * 2, pcm16, Endian.little);
    }

    final waveHdr = calloc<WAVEHDR>();
    waveHdr.ref.lpData = pcmDataPtr;
    waveHdr.ref.dwBufferLength = pcmBytesCount;
    waveHdr.ref.dwFlags = 0;

    final prepResult = _waveOutPrepareHeader!(_hWaveOut, waveHdr, sizeOf<WAVEHDR>());
    if (prepResult == 0) {
      _waveOutWrite!(_hWaveOut, waveHdr, sizeOf<WAVEHDR>());
    }

    Future.delayed(const Duration(milliseconds: 1600), () {
      try {
        calloc.free(pcmDataPtr);
        calloc.free(waveHdr);
      } catch (_) {}
    });
  }

  /// Closes WaveOut audio device handle cleanly when call ends
  void closeAudioDevice() {
    if (_isOpen && _hWaveOut != 0 && _waveOutClose != null) {
      try {
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
