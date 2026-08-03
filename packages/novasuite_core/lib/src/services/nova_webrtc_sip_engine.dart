import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sip_ua/sip_ua.dart';
import '../it_sky_sip_config.dart';

enum WebRtcCallState {
  idle,
  registering,
  registered,
  connecting,
  ringing,
  connected,
  disconnected,
  failed,
}

class NovaWebRtcSipEngine implements SipUaHelperListener {
  final SIPUAHelper _helper = SIPUAHelper();
  
  WebRtcCallState _state = WebRtcCallState.idle;
  Call? _activeCall;
  String? _lastError;
  bool _isMuted = false;

  final _stateController = StreamController<WebRtcCallState>.broadcast();
  Stream<WebRtcCallState> get onCallStateChanged => _stateController.stream;

  WebRtcCallState get state => _state;
  Call? get activeCall => _activeCall;
  String? get lastError => _lastError;
  bool get isMuted => _isMuted;

  NovaWebRtcSipEngine() {
    _helper.addSipUaHelperListener(this);
  }

  /// Initialize and register WSS SIP User Agent
  Future<void> initialize({
    String? wsUrl,
    String? username,
    String? password,
    String? domain,
  }) async {
    _setState(WebRtcCallState.registering);

    final targetWsUrl = wsUrl ?? ItSkySipConfig.wssPort7443Url;
    final targetUser = username ?? ItSkySipConfig.username;
    final targetPass = password ?? ItSkySipConfig.password;
    final targetDomain = domain ?? ItSkySipConfig.domain;

    final settings = UaSettings()
      ..webSocketUrl = targetWsUrl
      ..webSocketSettings.extraHeaders = {
        'Sec-WebSocket-Protocol': 'sip',
      }
      ..webSocketSettings.allowBadCertificate = true
      ..uri = 'sip:$targetUser@$targetDomain'
      ..authorizationUser = targetUser
      ..password = targetPass
      ..displayName = 'NovaCare Web Agent'
      ..userAgent = 'NovaCare-WebRTC/1.0 (SIP.js)'
      ..dtmfMode = DtmfMode.RFC2833
      ..register = true;

    try {
      _helper.start(settings);
    } catch (e) {
      _lastError = e.toString();
      _setState(WebRtcCallState.failed);
    }
  }

  /// Outbound Call Initiation
  Future<bool> makeCall(String targetNumber) async {
    final cleaned = ItSkySipConfig.formatOutboundDialString(targetNumber);
    final targetUri = 'sip:$cleaned@${ItSkySipConfig.domain}';

    _setState(WebRtcCallState.connecting);

    try {
      final success = await _helper.call(
        targetUri,
        voiceonly: true,
      );

      return success;
    } catch (e) {
      _lastError = e.toString();
      _setState(WebRtcCallState.failed);
      return false;
    }
  }

  /// Hang Up Call
  void hangup() {
    if (_activeCall != null) {
      _activeCall!.hangup();
      _activeCall = null;
    }
    _setState(WebRtcCallState.disconnected);
  }

  /// Toggle Audio Mute
  void toggleMute() {
    if (_activeCall != null) {
      _isMuted = !_isMuted;
      if (_isMuted) {
        _activeCall!.mute(true, false);
      } else {
        _activeCall!.unmute(true, false);
      }
    }
  }

  void _setState(WebRtcCallState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  // ==========================================================================
  // SipUaHelperListener Implementation
  // ==========================================================================

  @override
  void registrationStateChanged(RegistrationState state) {
    if (state.state == RegistrationStateEnum.REGISTERED) {
      _setState(WebRtcCallState.registered);
    } else if (state.state == RegistrationStateEnum.REGISTRATION_FAILED) {
      _lastError = 'SIP Registration Failed';
      _setState(WebRtcCallState.failed);
    }
  }

  @override
  void callStateChanged(Call call, CallState state) {
    _activeCall = call;

    switch (state.state) {
      case CallStateEnum.CONNECTING:
        _setState(WebRtcCallState.connecting);
        break;
      case CallStateEnum.PROGRESS:
        _setState(WebRtcCallState.ringing);
        break;
      case CallStateEnum.CONFIRMED:
        _setState(WebRtcCallState.connected);
        break;
      case CallStateEnum.ENDED:
      case CallStateEnum.FAILED:
        _setState(WebRtcCallState.disconnected);
        _activeCall = null;
        break;
      default:
        break;
    }
  }

  @override
  void transportStateChanged(TransportState state) {
    if (state.state == TransportStateEnum.DISCONNECTED) {
      debugPrint('⚠️ WebRTC Transport Disconnected');
    }
  }

  @override
  void onNewMessage(SIPMessageRequest msg) {}

  @override
  void onNewNotify(Notify request) {}

  void dispose() {
    _helper.removeSipUaHelperListener(this);
    _stateController.close();
  }
}
