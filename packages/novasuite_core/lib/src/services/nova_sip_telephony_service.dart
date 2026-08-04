import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sip_ua/sip_ua.dart';
import '../it_sky_sip_config.dart';
import '../models/order.dart';
import 'nova_udp_sip_engine.dart';

enum SipRegistrationStatus {
  unregistered,
  registering,
  registered,
  registrationFailed,
}

enum SipCallSessionState {
  idle,
  connectingProvider, // Stage 1: SIP Signaling over WSS
  initiatingCall,     // Stage 2: Ringing Feed
  incomingCall,       // Inbound Incoming Call Detected
  callInProgress,     // Stage 3: Active 2-Way Audio Stream
  callEnded,          // Stage 4: Billing Computation
  disconnected,       // Stage 5: Select Outcome Category
}

class NovaSipTelephonyService implements SipUaHelperListener {
  static final NovaSipTelephonyService _instance = NovaSipTelephonyService._internal();
  factory NovaSipTelephonyService() => _instance;
  
  final SIPUAHelper _sipHelper = SIPUAHelper();

  NovaSipTelephonyService._internal() {
    _sipHelper.addSipUaHelperListener(this);
    if (!kIsWeb && Platform.isWindows) {
      NovaUdpSipEngine().statusStream.listen((udpStatus) {
        switch (udpStatus) {
          case UdpSipStatus.unregistered:
            _notifyRegistrationStatus(SipRegistrationStatus.unregistered);
            break;
          case UdpSipStatus.registering:
            _notifyRegistrationStatus(SipRegistrationStatus.registering);
            break;
          case UdpSipStatus.registered:
            _notifyRegistrationStatus(SipRegistrationStatus.registered);
            if (_registrationCompleter != null && !_registrationCompleter!.isCompleted) {
              _registrationCompleter!.complete(true);
            }
            break;
          case UdpSipStatus.registrationFailed:
            _notifyRegistrationStatus(SipRegistrationStatus.registrationFailed);
            if (_registrationCompleter != null && !_registrationCompleter!.isCompleted) {
              _registrationCompleter!.complete(false);
            }
            break;
        }
      });

      NovaUdpSipEngine().callStateStream.listen((udpCallState) {
        switch (udpCallState) {
          case UdpCallState.idle:
            _notifyCallState(SipCallSessionState.idle);
            break;
          case UdpCallState.connecting:
            _notifyCallState(SipCallSessionState.connectingProvider);
            break;
          case UdpCallState.ringing:
            _notifyCallState(SipCallSessionState.initiatingCall);
            break;
          case UdpCallState.incomingCall:
            _notifyCallState(SipCallSessionState.incomingCall);
            break;
          case UdpCallState.active:
            _notifyCallState(SipCallSessionState.callInProgress);
            break;
          case UdpCallState.ended:
            _notifyCallState(SipCallSessionState.callEnded);
            break;
          case UdpCallState.disconnected:
            _notifyCallState(SipCallSessionState.disconnected);
            break;
        }
      });

      NovaUdpSipEngine().durationStream.listen((duration) {
        _notifyDuration(duration);
      });

      NovaUdpSipEngine().providerReasonStream.listen((reason) {
        _lastError = reason;
        if (!_providerReasonController.isClosed) {
          _providerReasonController.add(reason);
        }
      });
    }
  }

  SipRegistrationStatus _registrationStatus = SipRegistrationStatus.unregistered;
  SipCallSessionState _callState = SipCallSessionState.idle;
  
  Call? _activeSipCall;
  OrderModel? _activeOrder;
  int _callDurationSeconds = 0;
  Timer? _durationTimer;
  bool _isMuted = false;
  bool _isOnHold = false;
  String? _lastError;
  Completer<bool>? _registrationCompleter;
  int _activeUrlIndex = 0;

  final StreamController<SipRegistrationStatus> _regStatusController = StreamController.broadcast();
  final StreamController<SipCallSessionState> _callStateController = StreamController.broadcast();
  final StreamController<int> _durationController = StreamController.broadcast();
  final StreamController<String> _providerReasonController = StreamController.broadcast();

  Stream<SipRegistrationStatus> get registrationStatusStream => _regStatusController.stream;
  Stream<SipCallSessionState> get callStateStream => _callStateController.stream;
  Stream<int> get durationStream => _durationController.stream;
  Stream<String> get providerReasonStream => _providerReasonController.stream;

  SipRegistrationStatus get registrationStatus => _registrationStatus;
  SipCallSessionState get callState => _callState;
  int get callDurationSeconds => _callDurationSeconds;
  OrderModel? get activeOrder => _activeOrder;
  bool get isMuted => _isMuted;
  bool get isOnHold => _isOnHold;
  String? get lastError => _lastError;
  String? get incomingCallerNumber => NovaUdpSipEngine().incomingCallerNumber;

  Future<void> answerIncomingCall() async {
    if (!kIsWeb && Platform.isWindows) {
      await NovaUdpSipEngine().answerIncomingCall();
    } else {
      _activeSipCall?.answer({});
    }
  }

  void _notifyRegistrationStatus(SipRegistrationStatus status) {
    _registrationStatus = status;
    if (!_regStatusController.isClosed) {
      _regStatusController.add(_registrationStatus);
    }
  }

  void _notifyCallState(SipCallSessionState state) {
    _callState = state;
    if (!_callStateController.isClosed) {
      _callStateController.add(_callState);
    }
  }

  void _notifyDuration(int seconds) {
    _callDurationSeconds = seconds;
    if (!_durationController.isClosed) {
      _durationController.add(_callDurationSeconds);
    }
  }

  /// Registers NovaSuite Softphone with IT Sky ASTPP SIP Server over multi-transport endpoints
  Future<bool> registerSipTrunk({int urlIndex = 0}) async {
    if (!kIsWeb && Platform.isWindows) {
      return await NovaUdpSipEngine().registerUdpTrunk();
    }

    if (_registrationStatus == SipRegistrationStatus.registered && _sipHelper.registered) {
      return true;
    }

    _activeUrlIndex = urlIndex % ItSkySipConfig.fallbackWebSocketUrls.length;
    final currentUrl = ItSkySipConfig.fallbackWebSocketUrls[_activeUrlIndex];

    _registrationCompleter = Completer<bool>();
    _notifyRegistrationStatus(SipRegistrationStatus.registering);
    _lastError = null;

    final UaSettings settings = UaSettings();
    settings.webSocketUrl = currentUrl;
    settings.webSocketSettings.allowBadCertificate = true;
    settings.webSocketSettings.extraHeaders = {
      'Sec-WebSocket-Protocol': 'sip',
    };
    settings.uri = 'sip:${ItSkySipConfig.username}@${ItSkySipConfig.domain}';
    settings.authorizationUser = ItSkySipConfig.username;
    settings.password = ItSkySipConfig.password;
    settings.displayName = ItSkySipConfig.defaultDisplayName;
    settings.register = true;

    try {
      _sipHelper.start(settings);

      Timer(const Duration(seconds: 8), () {
        if (_registrationCompleter != null && !_registrationCompleter!.isCompleted) {
          if (_activeUrlIndex < ItSkySipConfig.fallbackWebSocketUrls.length - 1) {
            registerSipTrunk(urlIndex: _activeUrlIndex + 1);
          } else {
            // If WebSockets timed out on Windows, fallback to UDP engine
            if (!kIsWeb && Platform.isWindows) {
              NovaUdpSipEngine().registerUdpTrunk().then((success) {
                if (_registrationCompleter != null && !_registrationCompleter!.isCompleted) {
                  _notifyRegistrationStatus(success ? SipRegistrationStatus.registered : SipRegistrationStatus.registrationFailed);
                  _registrationCompleter?.complete(success);
                }
              });
            } else {
              _lastError = 'WSS Connection Failed on $currentUrl (Code 1006).';
              _notifyRegistrationStatus(SipRegistrationStatus.registrationFailed);
              _registrationCompleter?.complete(false);
            }
          }
        }
      });
    } catch (e) {
      _lastError = 'SIP Initialization Failed: $e';
      _notifyRegistrationStatus(SipRegistrationStatus.registrationFailed);
      _registrationCompleter?.complete(false);
    }

    return _registrationCompleter!.future;
  }

  /// Initiates Outbound SIP call with freeze-proof error guards
  Future<void> initiateCall(OrderModel order) async {
    _activeOrder = order;
    _callDurationSeconds = 0;
    _isMuted = false;
    _isOnHold = false;
    _lastError = null;

    _notifyCallState(SipCallSessionState.connectingProvider);

    if (!kIsWeb && Platform.isWindows) {
      await NovaUdpSipEngine().initiateCall(order);
      return;
    }

    final formattedPhone = ItSkySipConfig.formatOutboundDialString(order.customerPhone);
    final destinationUri = 'sip:$formattedPhone@${ItSkySipConfig.domain}';

    bool isRegistered = false;
    if (_registrationStatus == SipRegistrationStatus.registered && _sipHelper.registered) {
      isRegistered = true;
    } else {
      isRegistered = await registerSipTrunk();
    }

    if (!isRegistered) {
      if (!kIsWeb && Platform.isWindows) {
        await NovaUdpSipEngine().initiateCall(order);
        return;
      }
      _lastError = _lastError ?? 'SIP Trunk Connection Failed.';
      _notifyCallState(SipCallSessionState.disconnected);
      return;
    }

    try {
      _sipHelper.call(destinationUri);
    } catch (e) {
      _lastError = 'Call Dialing Error: $e';
      _notifyCallState(SipCallSessionState.disconnected);
    }
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _notifyDuration(_callDurationSeconds + 1);
    });
  }

  /// Toggle Audio Mute State
  void toggleMute() {
    _isMuted = !_isMuted;
    if (_activeSipCall != null) {
      try {
        if (_isMuted) {
          _activeSipCall!.mute(true, false);
        } else {
          _activeSipCall!.unmute(true, false);
        }
      } catch (_) {}
    }
  }

  /// Toggle Call Hold State
  void toggleHold() {
    _isOnHold = !_isOnHold;
    if (_activeSipCall != null) {
      try {
        if (_isOnHold) {
          _activeSipCall!.hold();
          _durationTimer?.cancel();
        } else {
          _activeSipCall!.unhold();
          if (_callState == SipCallSessionState.callInProgress) {
            _startDurationTimer();
          }
        }
      } catch (_) {}
    }
  }

  /// Sends DTMF Dialpad Tones (0-9, *, #) over real SIP INFO / RFC 2833
  void sendDtmf(String tone) {
    if (_activeSipCall != null) {
      try {
        _activeSipCall!.sendDTMF(tone);
      } catch (_) {}
    }
  }

  void rejectIncomingCall() {
    if (!kIsWeb && Platform.isWindows) {
      NovaUdpSipEngine().rejectIncomingCall();
      return;
    }
    if (_activeSipCall != null) {
      _activeSipCall!.hangup();
    }
  }

  /// Ends the active SIP call session
  void endCall() {
    if (!kIsWeb && Platform.isWindows) {
      NovaUdpSipEngine().endCall();
      return;
    }
    _durationTimer?.cancel();
    if (_activeSipCall != null) {
      try {
        _activeSipCall!.hangup();
      } catch (_) {}
    }
    _notifyCallState(SipCallSessionState.callEnded);
    Timer(const Duration(milliseconds: 1500), () {
      _notifyCallState(SipCallSessionState.disconnected);
    });
  }

  /// Calculates call billing cost (₦14.75 per minute, rounded up)
  double calculateCallBillingCost() {
    if (_callDurationSeconds == 0) return 0.00;
    final minutes = (_callDurationSeconds / 60).ceil();
    return minutes * 14.75;
  }

  /// Resets session after call completion
  void resetSession() {
    _durationTimer?.cancel();
    _activeSipCall = null;
    _activeOrder = null;
    _callDurationSeconds = 0;
    _isMuted = false;
    _isOnHold = false;
    _lastError = null;
    _notifyCallState(SipCallSessionState.idle);
  }

  String formatDuration(int totalSeconds) {
    final mins = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  // ============================================================================
  // SipUaHelperListener Callbacks
  // ============================================================================

  @override
  void registrationStateChanged(RegistrationState state) {
    switch (state.state) {
      case RegistrationStateEnum.REGISTERED:
        _notifyRegistrationStatus(SipRegistrationStatus.registered);
        if (_registrationCompleter != null && !_registrationCompleter!.isCompleted) {
          _registrationCompleter!.complete(true);
        }
        break;
      case RegistrationStateEnum.REGISTRATION_FAILED:
        _notifyRegistrationStatus(SipRegistrationStatus.registrationFailed);
        if (_registrationCompleter != null && !_registrationCompleter!.isCompleted) {
          _registrationCompleter!.complete(false);
        }
        break;
      case RegistrationStateEnum.UNREGISTERED:
        _notifyRegistrationStatus(SipRegistrationStatus.unregistered);
        break;
      default:
        break;
    }
  }

  @override
  void callStateChanged(Call call, CallState state) {
    _activeSipCall = call;

    switch (state.state) {
      case CallStateEnum.CONNECTING:
      case CallStateEnum.PROGRESS:
        _notifyCallState(SipCallSessionState.initiatingCall); // Ringing stage
        break;
      case CallStateEnum.CONFIRMED:
        _notifyCallState(SipCallSessionState.callInProgress); // Active Audio
        _startDurationTimer();
        break;
      case CallStateEnum.ENDED:
      case CallStateEnum.FAILED:
        _durationTimer?.cancel();
        _notifyCallState(SipCallSessionState.callEnded);
        Timer(const Duration(milliseconds: 1200), () {
          _notifyCallState(SipCallSessionState.disconnected);
        });
        break;
      default:
        break;
    }
  }

  @override
  void transportStateChanged(TransportState state) {
    if (state.state == TransportStateEnum.DISCONNECTED) {
      _lastError = 'WSS Transport Disconnected from ${ItSkySipConfig.fallbackWebSocketUrls[_activeUrlIndex]}';
    }
  }

  @override
  void onNewMessage(SIPMessageRequest request) {}

  @override
  void onNewNotify(dynamic notification) {}

  /// Closes active timers and stream controllers on app shutdown
  void dispose() {
    _durationTimer?.cancel();
    _sipHelper.removeSipUaHelperListener(this);
    _sipHelper.stop();
    _regStatusController.close();
    _callStateController.close();
    _durationController.close();
  }
}
