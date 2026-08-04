import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import '../it_sky_sip_config.dart';
import '../models/order.dart';
import 'nova_winmm_audio_driver.dart';
import '../telephony/data/recorders/wave_call_recorder.dart';
import '../telephony/data/storage/supabase_media_storage_service.dart';
import 'nova_windows_focus_service.dart';

enum UdpSipStatus {
  unregistered,
  registering,
  registered,
  registrationFailed,
}

enum UdpCallState {
  idle,
  connecting,
  ringing,
  incomingCall,
  active,
  ended,
  disconnected,
}

/// Native UDP SIP Telephony Engine mirroring MicroSIP exactly over raw UDP socket (Port 5060)
class NovaUdpSipEngine {
  static final NovaUdpSipEngine _instance = NovaUdpSipEngine._internal();
  factory NovaUdpSipEngine() => _instance;

  NovaUdpSipEngine._internal();

  RawDatagramSocket? _socket;
  UdpSipStatus _status = UdpSipStatus.unregistered;
  UdpCallState _callState = UdpCallState.idle;

  int _cseq = 100;
  String? _lastNonce;
  OrderModel? _activeOrder;
  int _callDuration = 0;
  Timer? _durationTimer;
  String? _lastError;

  final StreamController<UdpSipStatus> _statusController = StreamController.broadcast();
  final StreamController<UdpCallState> _callStateController = StreamController.broadcast();
  final StreamController<int> _durationController = StreamController.broadcast();
  final StreamController<String> _providerReasonController = StreamController.broadcast();

  Stream<UdpSipStatus> get statusStream => _statusController.stream;
  Stream<UdpCallState> get callStateStream => _callStateController.stream;
  Stream<int> get durationStream => _durationController.stream;
  Stream<String> get providerReasonStream => _providerReasonController.stream;

  UdpSipStatus get status => _status;
  UdpCallState get callState => _callState;
  OrderModel? get activeOrder => _activeOrder;
  int get callDuration => _callDuration;
  String? get lastError => _lastError;
  String? get incomingCallerNumber => _incomingCallerNumber;

  void _notifyStatus(UdpSipStatus newStatus) {
    _status = newStatus;
    if (!_statusController.isClosed) {
      _statusController.add(_status);
    }
  }

  void _notifyCallState(UdpCallState newState) {
    _callState = newState;
    if (!_callStateController.isClosed) {
      _callStateController.add(_callState);
    }
    if (newState == UdpCallState.disconnected) {
      _callState = UdpCallState.idle;
      _activeCallId = null;
      _activeFromTag = null;
      _activeToTag = null;
      _activeInviteMsg = null;
      _incomingCallerNumber = null;
      _remoteContactUri = null;
      _activeOrder = null;
    }
  }

  void _notifyDuration(int seconds) {
    _callDuration = seconds;
    if (!_durationController.isClosed) {
      _durationController.add(_callDuration);
    }
  }

  Completer<bool>? _registerCompleter;

  /// Initializes UDP Socket on Port 5060 or ephemeral port and registers with OpenSIPS/ASTPP PBX
  Future<bool> registerUdpTrunk() async {
    if (_status == UdpSipStatus.registered) return true;
    if (_status == UdpSipStatus.registering && _registerCompleter != null && !_registerCompleter!.isCompleted) {
      print('📡 [UDP SIP] Registration already in progress... reusing existing listener completer.');
      return _registerCompleter!.future;
    }

    print('📡 [UDP SIP] Starting registration with IT Sky SIP server (${ItSkySipConfig.providerSipHost}:${ItSkySipConfig.providerSipPort})...');
    _notifyStatus(UdpSipStatus.registering);
    _lastError = null;
    _registerCompleter = Completer<bool>();

    try {
      if (_socket == null) {
        _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
        print('✅ [UDP SIP] Local UDP Socket bound on port: ${_socket!.port}');
        _socket!.listen(_handleIncomingDatagram);
      }

      _sendRegisterPacket();
      
      // Safety timeout after 5 seconds
      Timer(const Duration(seconds: 5), () {
        if (_registerCompleter != null && !_registerCompleter!.isCompleted) {
          print('⚠️ [UDP SIP] Registration timed out waiting for 200 OK response');
          _notifyStatus(UdpSipStatus.registrationFailed);
          _registerCompleter!.complete(false);
        }
      });
    } catch (e) {
      print('❌ [UDP SIP] Socket Error: $e');
      _lastError = 'UDP Socket Error: $e';
      _notifyStatus(UdpSipStatus.registrationFailed);
      _registerCompleter?.complete(false);
    }

    return _registerCompleter!.future;
  }

  /// Sends raw SIP REGISTER packet to OpenSIPS Host 95.217.244.97:5060
  void _sendRegisterPacket([String? authHeader]) {
    _cseq++;
    final callId = 'novasuite-call-${DateTime.now().millisecondsSinceEpoch}@${_socket?.address.address ?? '0.0.0.0'}';
    final viaBranch = 'z9hG4bK-nova-${DateTime.now().millisecondsSinceEpoch}';

    final StringBuffer sipMsg = StringBuffer();
    sipMsg.writeln('REGISTER sip:${ItSkySipConfig.domain} SIP/2.0');
    sipMsg.writeln('Via: SIP/2.0/UDP ${_socket?.address.address ?? '0.0.0.0'}:${_socket?.port ?? 5060};rport;branch=$viaBranch');
    sipMsg.writeln('Max-Forwards: 70');
    sipMsg.writeln('From: <sip:${ItSkySipConfig.username}@${ItSkySipConfig.domain}>;tag=nova${DateTime.now().millisecondsSinceEpoch}');
    sipMsg.writeln('To: <sip:${ItSkySipConfig.username}@${ItSkySipConfig.domain}>');
    sipMsg.writeln('Call-ID: $callId');
    sipMsg.writeln('CSeq: $_cseq REGISTER');
    sipMsg.writeln('Contact: <sip:${ItSkySipConfig.username}@${_socket?.address.address ?? '0.0.0.0'}:${_socket?.port ?? 5060}>');
    sipMsg.writeln('User-Agent: MicroSIP/3.21.3');
    sipMsg.writeln('Expires: 300');
    if (authHeader != null) {
      sipMsg.writeln('Authorization: $authHeader');
    }
    sipMsg.writeln('Content-Length: 0');
    sipMsg.writeln('');

    print('📡 [UDP SIP] Outbound REGISTER packet sent (CSeq: $_cseq)');
    final bytes = utf8.encode(sipMsg.toString());
    _socket?.send(bytes, InternetAddress(ItSkySipConfig.providerSipHost), ItSkySipConfig.providerSipPort);
  }

  /// Sends raw SIP REGISTER packet with Expires: 0 to OpenSIPS Host to immediately unregister line on app exit
  void unregisterUdpTrunk() {
    if (_socket == null) return;
    _cseq++;
    final callId = 'novasuite-call-${DateTime.now().millisecondsSinceEpoch}@${_socket?.address.address ?? '0.0.0.0'}';
    final viaBranch = 'z9hG4bK-nova-${DateTime.now().millisecondsSinceEpoch}';

    final StringBuffer sipMsg = StringBuffer();
    sipMsg.writeln('REGISTER sip:${ItSkySipConfig.domain} SIP/2.0');
    sipMsg.writeln('Via: SIP/2.0/UDP ${_socket?.address.address ?? '0.0.0.0'}:${_socket?.port ?? 5060};rport;branch=$viaBranch');
    sipMsg.writeln('Max-Forwards: 70');
    sipMsg.writeln('From: <sip:${ItSkySipConfig.username}@${ItSkySipConfig.domain}>;tag=nova${DateTime.now().millisecondsSinceEpoch}');
    sipMsg.writeln('To: <sip:${ItSkySipConfig.username}@${ItSkySipConfig.domain}>');
    sipMsg.writeln('Call-ID: $callId');
    sipMsg.writeln('CSeq: $_cseq REGISTER');
    sipMsg.writeln('Contact: *');
    sipMsg.writeln('User-Agent: MicroSIP/3.21.3');
    sipMsg.writeln('Expires: 0');
    sipMsg.writeln('Content-Length: 0');
    sipMsg.writeln('');

    print('📡 [UDP SIP] Outbound Un-REGISTER packet sent (Expires: 0)');
    final bytes = utf8.encode(sipMsg.toString());
    _socket?.send(bytes, InternetAddress(ItSkySipConfig.providerSipHost), ItSkySipConfig.providerSipPort);
    _socket?.close();
    _socket = null;
    _status = UdpSipStatus.unregistered;
  }

  /// Handles incoming UDP packets from OpenSIPS PBX (SIP text packets & binary RTP audio stream)
  void _handleIncomingDatagram(RawSocketEvent event) {
    if (event == RawSocketEvent.read) {
      final datagram = _socket?.receive();
      if (datagram == null || datagram.data.isEmpty) return;

      // 1. Detect binary RTP audio stream packet (RTP v2 header byte 0x80 / 0x88 / 0x84)
      if ((datagram.data[0] & 0xC0) == 0x80 && datagram.data.length > 12) {
        if (_callState == UdpCallState.active || _callState == UdpCallState.ringing || _callState == UdpCallState.connecting) {
          _processIncomingRtpAudioPayload(datagram.data);
        }
        return;
      }

      // 2. Parse text SIP Signaling packets
      String message;
      try {
        message = utf8.decode(datagram.data);
      } catch (_) {
        return; // Ignore non-UTF8 binary data
      }

      final firstLine = message.split('\r\n').first;
      print('📥 [UDP SIP] Received Datagram: $firstLine');

      if (message.contains('SIP/2.0 401 Unauthorized')) {
        print('🔒 [UDP SIP] Received 401 Unauthorized Challenge -> Resolving MD5 Digest...');
        _handle401Challenge(message);
      } else if (message.contains('SIP/2.0 407 Proxy Authentication Required')) {
        print('🔒 [UDP SIP] Received 407 Proxy Authentication Challenge -> Resolving INVITE MD5 Digest...');
        _handle407Challenge(message);
      } else if (message.contains('SIP/2.0 200 OK')) {
        print('🎉 [UDP SIP] Received 200 OK Response from OpenSIPS!');
        if (_status == UdpSipStatus.registering) {
          _notifyStatus(UdpSipStatus.registered);
          _startKeepAliveTimer();
          if (_registerCompleter != null && !_registerCompleter!.isCompleted) {
            _registerCompleter!.complete(true);
          }
        } else if (_callState == UdpCallState.ringing || _callState == UdpCallState.connecting) {
          print('📞 [UDP SIP] Call Answered! Audio stream active.');
          _parseSdpAnswer(message);
          _stopRingbackTone();
          _sendAckPacket(message);
          _startRtpAudioSession();
          _notifyCallState(UdpCallState.active);
          _startTimer();
        }
      } else if (message.contains('183 Session Progress')) {
        print('🎵 [UDP SIP] 183 Session Progress - Enabling In-Band Early Media (Operator Voice Announcements)...');
        _hasEarlyMedia = true;
        _notifyProviderReason(firstLine, message);
        _parseSdpAnswer(message);
        _startRingbackTone();
        _startEarlyMediaSession();
        _notifyCallState(UdpCallState.ringing);
      } else if (message.contains('180 Ringing')) {
        print('🔔 [UDP SIP] Remote Phone Ringing (180)...');
        _notifyProviderReason(firstLine, message);
        _parseSdpAnswer(message);
        _startRingbackTone();
        _notifyCallState(UdpCallState.ringing);
      } else if (message.startsWith('INVITE') || message.contains('\r\nINVITE ')) {
        _handleIncomingInviteRequest(message);
      } else if (message.startsWith('CANCEL') || message.contains('\r\nCANCEL ')) {
        _handleIncomingCancelRequest(message);
      } else if (message.startsWith('BYE') || message.contains('\r\nBYE ')) {
        print('⏹️ [UDP SIP] Received BYE from OpenSIPS (Remote Customer Hung Up). Sending 200 OK ACK...');
        _notifyProviderReason(firstLine, message);
        _sendBye200OKResponse(message);
        if (_callState != UdpCallState.ended && _callState != UdpCallState.disconnected) {
          _durationTimer?.cancel();
          _stopRingbackTone();
          _notifyCallState(UdpCallState.ended);
          _notifyCallState(UdpCallState.disconnected);
        }
      } else if (message.contains('486 Busy') || message.contains('603 Decline') || message.contains('480 Temporarily Unavailable') || message.contains('487 Request Terminated')) {
        if (_callState != UdpCallState.ended && _callState != UdpCallState.disconnected) {
          print('⏹️ [UDP SIP] Call Terminated by Remote / PBX (Reason: $firstLine). Sending ACK...');
          _notifyProviderReason(firstLine, message);
          _sendAckPacket(message);
          _notifyCallState(UdpCallState.ended);
          _durationTimer?.cancel();
          final delayMs = _hasEarlyMedia ? 5500 : 1500;
          print('⏳ [UDP SIP] Delaying outcome screen transition by ${delayMs}ms to allow operator voice prompt to finish playing...');
          Timer(Duration(milliseconds: delayMs), () {
            _stopRingbackTone();
            _notifyCallState(UdpCallState.disconnected);
          });
        }
      }
    }
  }

  String? _incomingCallerNumber;
  String? _activeToTag;
  String? _activeInviteMsg;
  String? _remoteContactUri;

  void _handleIncomingInviteRequest(String inviteMsg) {
    _activeInviteMsg = inviteMsg;
    // 1. Extract Call-ID
    final callIdMatch = RegExp(r'Call-ID: ([^\r\n]+)', caseSensitive: false).firstMatch(inviteMsg);
    final incomingCallId = callIdMatch?.group(1)!.trim();

    // Guard 1: If we are ALREADY in an active call, connecting, ringing, or ending a call, reject with 486 Busy Here!
    if (_callState != UdpCallState.idle && _callState != UdpCallState.disconnected && _activeCallId != incomingCallId) {
      print('⛔ [UDP SIP] Line is BUSY (Current state: $_callState, Active Call-ID: $_activeCallId). Rejecting incoming INVITE ($incomingCallId) with 486 Busy Here.');
      _sendSip486BusyResponse(inviteMsg);
      return;
    }

    // Guard 2: Guard against duplicate re-transmitted INVITE packets for the active incoming call
    if (_activeCallId != null && _activeCallId == incomingCallId && (_callState == UdpCallState.incomingCall || _callState == UdpCallState.active)) {
      print('🔁 [UDP SIP] Re-transmitting 180 Ringing response for active Call-ID ($incomingCallId)...');
      _send180RingingResponse(inviteMsg);
      return;
    }

    _activeCallId = incomingCallId;
    print('📞 [UDP SIP] INCOMING CALL DETECTED FROM OPENSIPS PBX! (Call-ID: $_activeCallId)');

    // Extract Contact URI for RFC 3261 compliant BYE target
    final contactMatch = RegExp(r'Contact:\s*<([^>]+)>', caseSensitive: false).firstMatch(inviteMsg);
    if (contactMatch != null) {
      _remoteContactUri = contactMatch.group(1)!.trim();
    } else {
      final contactMatch2 = RegExp(r'Contact:\s*([^\r\n;]+)', caseSensitive: false).firstMatch(inviteMsg);
      if (contactMatch2 != null) {
        _remoteContactUri = contactMatch2.group(1)!.trim();
      }
    }

    // 2. Extract From header & caller phone number
    final fromMatch = RegExp(r'From: ([^\r\n]+)', caseSensitive: false).firstMatch(inviteMsg);
    if (fromMatch != null) {
      final fromStr = fromMatch.group(1)!;
      final tagMatch = RegExp(r'tag=([^\s;;\r\n]+)').firstMatch(fromStr);
      if (tagMatch != null) {
        _activeFromTag = tagMatch.group(1);
      }
      final phoneMatch = RegExp(r'sip:(\d+)@').firstMatch(fromStr);
      if (phoneMatch != null) {
        _incomingCallerNumber = phoneMatch.group(1);
      } else {
        _incomingCallerNumber = 'Customer Call';
      }
    }

    _activeToTag = 'nova-inc-${DateTime.now().millisecondsSinceEpoch}';
    _parseSdpAnswer(inviteMsg);
    _notifyProviderReason('INCOMING CALL', '📞 Incoming Call from ${_incomingCallerNumber ?? "Customer"}');

    // 3. Send 180 Ringing response to OpenSIPS so the caller hears phone ringing!
    _send180RingingResponse(inviteMsg);
    _startRingbackTone();
    _notifyCallState(UdpCallState.incomingCall);

    // 4. Force Windows app to un-minimize, restore to foreground focus, and flash taskbar icon!
    NovaWindowsFocusService().bringAppToForegroundAndFlash();
  }

  void _handleIncomingCancelRequest(String cancelMsg) {
    print('⏹️ [UDP SIP] Received CANCEL from OpenSIPS. Sending 200 OK response...');
    _stopRingbackTone();

    _sendCancel200OKResponse(cancelMsg);

    // Per SIP RFC 3261 Section 9.2: CANCEL has no effect if 200 OK final response was already sent!
    if (_callState == UdpCallState.active) {
      print('ℹ️ [UDP SIP] Call is ALREADY ACTIVE (200 OK answered). Ignoring late CANCEL request.');
      return;
    }

    _send487RequestTerminatedResponse(cancelMsg);

    _activeCallId = null;
    _activeFromTag = null;
    _activeToTag = null;

    _notifyCallState(UdpCallState.ended);
    Timer(const Duration(milliseconds: 200), () {
      _notifyCallState(UdpCallState.disconnected);
    });
  }

  void _sendCancel200OKResponse(String cancelMsg) {
    final viaMatch = RegExp(r'Via: ([^\r\n]+)', caseSensitive: false).firstMatch(cancelMsg);
    final fromMatch = RegExp(r'From: ([^\r\n]+)', caseSensitive: false).firstMatch(cancelMsg);
    final toMatch = RegExp(r'To: ([^\r\n]+)', caseSensitive: false).firstMatch(cancelMsg);
    final callIdMatch = RegExp(r'Call-ID: ([^\r\n]+)', caseSensitive: false).firstMatch(cancelMsg);
    final cseqMatch = RegExp(r'CSeq: ([^\r\n]+)', caseSensitive: false).firstMatch(cancelMsg);

    final sipMsg = StringBuffer();
    sipMsg.writeln('SIP/2.0 200 OK');
    if (viaMatch != null) sipMsg.writeln(viaMatch.group(0));
    if (fromMatch != null) sipMsg.writeln(fromMatch.group(0));
    if (toMatch != null) sipMsg.writeln(toMatch.group(0));
    if (callIdMatch != null) sipMsg.writeln(callIdMatch.group(0));
    if (cseqMatch != null) sipMsg.writeln(cseqMatch.group(0));
    sipMsg.writeln('User-Agent: NovaSuite Engine v1.0 (Windows)');
    sipMsg.writeln('Content-Length: 0');
    sipMsg.writeln();

    _sendDatagram(sipMsg.toString());
  }

  void _send487RequestTerminatedResponse(String cancelMsg) {
    final viaMatch = RegExp(r'Via: ([^\r\n]+)', caseSensitive: false).firstMatch(cancelMsg);
    final fromMatch = RegExp(r'From: ([^\r\n]+)', caseSensitive: false).firstMatch(cancelMsg);
    final toMatch = RegExp(r'To: ([^\r\n]+)', caseSensitive: false).firstMatch(cancelMsg);
    final callIdMatch = RegExp(r'Call-ID: ([^\r\n]+)', caseSensitive: false).firstMatch(cancelMsg);

    final sipMsg = StringBuffer();
    sipMsg.writeln('SIP/2.0 487 Request Terminated');
    if (viaMatch != null) sipMsg.writeln(viaMatch.group(0));
    if (fromMatch != null) sipMsg.writeln(fromMatch.group(0));
    if (toMatch != null) sipMsg.writeln(toMatch.group(0));
    if (callIdMatch != null) sipMsg.writeln(callIdMatch.group(0));
    sipMsg.writeln('CSeq: 1 INVITE');
    sipMsg.writeln('User-Agent: NovaSuite Engine v1.0 (Windows)');
    sipMsg.writeln('Content-Length: 0');
    sipMsg.writeln();

    _sendDatagram(sipMsg.toString());
  }

  void _sendDatagram(String sipMsg) {
    final bytes = utf8.encode(sipMsg);
    _socket?.send(bytes, InternetAddress(ItSkySipConfig.providerSipHost), ItSkySipConfig.providerSipPort);
  }

  void _send180RingingResponse(String inviteMsg) async {
    final viaMatches = RegExp(r'^Via:\s*[^\r\n]+', caseSensitive: false, multiLine: true).allMatches(inviteMsg);
    final viaHeaders = viaMatches.map((m) => m.group(0)!).toList();

    final fromMatch = RegExp(r'^From:\s*[^\r\n]+', caseSensitive: false, multiLine: true).firstMatch(inviteMsg);
    final fromHeader = fromMatch?.group(0) ?? 'From: <sip:unknown@${ItSkySipConfig.domain}>';

    final toMatch = RegExp(r'^To:\s*[^\r\n]+', caseSensitive: false, multiLine: true).firstMatch(inviteMsg);
    String toHeader = toMatch?.group(0) ?? 'To: <sip:${ItSkySipConfig.username}@${ItSkySipConfig.domain}>';
    if (!toHeader.contains('tag=')) {
      toHeader = '$toHeader;tag=$_activeToTag';
    }

    final callIdMatch = RegExp(r'^Call-ID:\s*[^\r\n]+', caseSensitive: false, multiLine: true).firstMatch(inviteMsg);
    final callIdHeader = callIdMatch?.group(0) ?? 'Call-ID: $_activeCallId';

    final cseqMatch = RegExp(r'^CSeq:\s*[^\r\n]+', caseSensitive: false, multiLine: true).firstMatch(inviteMsg);
    final cseqHeader = cseqMatch?.group(0) ?? 'CSeq: 1 INVITE';

    final sipMsg = StringBuffer();
    sipMsg.writeln('SIP/2.0 180 Ringing');
    for (final via in viaHeaders) {
      sipMsg.writeln(via);
    }
    sipMsg.writeln(fromHeader);
    sipMsg.writeln(toHeader);
    sipMsg.writeln(callIdHeader);
    sipMsg.writeln(cseqHeader);
    sipMsg.writeln('User-Agent: MicroSIP/3.21.3');
    sipMsg.writeln('Content-Length: 0');
    sipMsg.writeln();

    _sendDatagram(sipMsg.toString());
    print('📡 [UDP SIP] Sent RFC 3261 Compliant 180 Ringing response with exact Via header.');
  }

  Timer? _keepAliveTimer;

  void _startKeepAliveTimer() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (_status == UdpSipStatus.registered && _socket != null) {
        // Send CRLF keep-alive ping to maintain NAT binding (RFC 5626)
        _socket?.send(utf8.encode('\r\n\r\n'), InternetAddress(ItSkySipConfig.providerSipHost), ItSkySipConfig.providerSipPort);
      }
    });
  }

  Future<void> answerIncomingCall() async {
    print('📞 [UDP SIP] Answering Inbound Call from $_incomingCallerNumber...');
    _stopRingbackTone();
    await _send200OKAnswerResponse();
    _startRtpAudioSession();
    _notifyCallState(UdpCallState.active);
    _startTimer();
  }

  void rejectIncomingCall() {
    print('⛔ [UDP SIP] Rejecting Inbound Call from $_incomingCallerNumber...');
    _stopRingbackTone();
    _sendSipResponse('486 Busy Here');
    _notifyCallState(UdpCallState.ended);
    Timer(const Duration(milliseconds: 1000), () {
      _notifyCallState(UdpCallState.disconnected);
    });
  }

  void _sendSipResponse(String statusCode) {
    final viaBranch = 'z9hG4bK-nova-${DateTime.now().millisecondsSinceEpoch}';
    final StringBuffer sipMsg = StringBuffer();
    sipMsg.writeln('SIP/2.0 $statusCode');
    sipMsg.writeln('Via: SIP/2.0/UDP ${ItSkySipConfig.providerSipHost}:${ItSkySipConfig.providerSipPort};rport;branch=$viaBranch');
    sipMsg.writeln('From: <sip:${_incomingCallerNumber}@${ItSkySipConfig.domain}>;tag=$_activeFromTag');
    sipMsg.writeln('To: <sip:${ItSkySipConfig.username}@${ItSkySipConfig.domain}>;tag=$_activeToTag');
    sipMsg.writeln('Call-ID: $_activeCallId');
    sipMsg.writeln('CSeq: 1 INVITE');
    sipMsg.writeln('User-Agent: MicroSIP/3.21.3');
    sipMsg.writeln('Content-Length: 0');
    sipMsg.writeln('');

    final bytes = utf8.encode(sipMsg.toString());
    _socket?.send(bytes, InternetAddress(ItSkySipConfig.providerSipHost), ItSkySipConfig.providerSipPort);
  }

  void _sendSip486BusyResponse(String inviteMsg) {
    final callIdMatch = RegExp(r'Call-ID: ([^\r\n]+)', caseSensitive: false).firstMatch(inviteMsg);
    final callId = callIdMatch?.group(1)!.trim() ?? _activeCallId ?? 'unknown';

    final fromMatch = RegExp(r'From: ([^\r\n]+)', caseSensitive: false).firstMatch(inviteMsg);
    final fromHeader = fromMatch != null ? 'From: ${fromMatch.group(1)}' : 'From: <sip:unknown@${ItSkySipConfig.domain}>';

    final toMatch = RegExp(r'To: ([^\r\n]+)', caseSensitive: false).firstMatch(inviteMsg);
    final toHeader = toMatch != null ? 'To: ${toMatch.group(1)};tag=nova-busy-${DateTime.now().millisecondsSinceEpoch}' : 'To: <sip:${ItSkySipConfig.username}@${ItSkySipConfig.domain}>;tag=nova-busy-${DateTime.now().millisecondsSinceEpoch}';

    final StringBuffer sipMsg = StringBuffer();
    sipMsg.writeln('SIP/2.0 486 Busy Here');
    sipMsg.writeln('Via: SIP/2.0/UDP ${ItSkySipConfig.providerSipHost}:${ItSkySipConfig.providerSipPort};rport;branch=z9hG4bK-nova-busy-${DateTime.now().millisecondsSinceEpoch}');
    sipMsg.writeln(fromHeader);
    sipMsg.writeln(toHeader);
    sipMsg.writeln('Call-ID: $callId');
    sipMsg.writeln('CSeq: 1 INVITE');
    sipMsg.writeln('User-Agent: MicroSIP/3.21.3');
    sipMsg.writeln('Content-Length: 0');
    sipMsg.writeln('');

    final bytes = utf8.encode(sipMsg.toString());
    _socket?.send(bytes, InternetAddress(ItSkySipConfig.providerSipHost), ItSkySipConfig.providerSipPort);
    print('📡 [UDP SIP] Sent 486 Busy Here response to OpenSIPS for Call-ID: $callId');
  }

  Future<void> _send200OKAnswerResponse() async {
    if (_activeInviteMsg == null) {
      print('⚠️ [UDP SIP] Cannot send 200 OK: missing active INVITE message.');
      return;
    }

    final localIp = await _getLocalIpAddress();
    final port = _socket?.port ?? 5060;

    final viaMatches = RegExp(r'^Via:\s*[^\r\n]+', caseSensitive: false, multiLine: true).allMatches(_activeInviteMsg!);
    final viaHeaders = viaMatches.map((m) => m.group(0)!).toList();

    final fromMatch = RegExp(r'^From:\s*[^\r\n]+', caseSensitive: false, multiLine: true).firstMatch(_activeInviteMsg!);
    final fromHeader = fromMatch?.group(0) ?? 'From: <sip:${_incomingCallerNumber}@${ItSkySipConfig.domain}>;tag=$_activeFromTag';

    final toMatch = RegExp(r'^To:\s*[^\r\n]+', caseSensitive: false, multiLine: true).firstMatch(_activeInviteMsg!);
    String toHeader = toMatch?.group(0) ?? 'To: <sip:${ItSkySipConfig.username}@${ItSkySipConfig.domain}>';
    if (!toHeader.contains('tag=')) {
      toHeader = '$toHeader;tag=$_activeToTag';
    }

    final callIdMatch = RegExp(r'^Call-ID:\s*[^\r\n]+', caseSensitive: false, multiLine: true).firstMatch(_activeInviteMsg!);
    final callIdHeader = callIdMatch?.group(0) ?? 'Call-ID: $_activeCallId';

    final cseqMatch = RegExp(r'^CSeq:\s*[^\r\n]+', caseSensitive: false, multiLine: true).firstMatch(_activeInviteMsg!);
    final cseqHeader = cseqMatch?.group(0) ?? 'CSeq: 1 INVITE';

    final sdpBody = StringBuffer();
    sdpBody.writeln('v=0');
    sdpBody.writeln('o=- ${DateTime.now().millisecondsSinceEpoch} 1 IN IP4 $localIp');
    sdpBody.writeln('s=NovaSuite Core Audio');
    sdpBody.writeln('c=IN IP4 $localIp');
    sdpBody.writeln('t=0 0');
    sdpBody.writeln('m=audio $port RTP/AVP 0 101');
    sdpBody.writeln('a=rtpmap:0 PCMU/8000');
    sdpBody.writeln('a=rtpmap:101 telephone-event/8000');
    sdpBody.writeln('a=fmtp:101 0-15');
    sdpBody.writeln('a=sendrecv');

    final sdpBytes = utf8.encode(sdpBody.toString());

    final sipMsg = StringBuffer();
    sipMsg.writeln('SIP/2.0 200 OK');
    for (final via in viaHeaders) {
      sipMsg.writeln(via);
    }
    sipMsg.writeln(fromHeader);
    sipMsg.writeln(toHeader);
    sipMsg.writeln(callIdHeader);
    sipMsg.writeln(cseqHeader);
    sipMsg.writeln('Contact: <sip:${ItSkySipConfig.username}@$localIp:$port>');
    sipMsg.writeln('User-Agent: MicroSIP/3.21.3');
    sipMsg.writeln('Content-Type: application/sdp');
    sipMsg.writeln('Content-Length: ${sdpBytes.length}');
    sipMsg.writeln();
    sipMsg.write(sdpBody.toString());

    _sendDatagram(sipMsg.toString());
    print('📡 [UDP SIP] Sent RFC 3261 Compliant 200 OK Answer Response with exact Via header.');
  }

  void _notifyProviderReason(String firstLine, String message) {
    String humanReason = firstLine;
    if (message.contains('486 Busy') || message.contains('Busy Here')) {
      humanReason = '🔴 Customer Busy on Another Call (486)';
    } else if (message.contains('480 Temporarily Unavailable') || message.contains('Unavailable')) {
      humanReason = '🟡 Customer Line Switched Off / Out of Coverage (480)';
    } else if (message.contains('404 Not Found')) {
      humanReason = '❌ Invalid / Unassigned Phone Number (404)';
    } else if (message.contains('603 Decline')) {
      humanReason = '⛔ Call Rejected by Customer (603)';
    } else if (message.contains('183 Session Progress')) {
      humanReason = '📢 Telecom Operator Announcement (183)';
    } else if (message.contains('180 Ringing')) {
      humanReason = '🔔 Customer Phone Ringing (180)';
    }
    if (message.contains('486') || message.contains('480') || message.contains('404') || message.contains('603')) {
      _lastError = humanReason;
    } else {
      _lastError = null;
    }
    if (!_providerReasonController.isClosed) {
      _providerReasonController.add(humanReason);
    }
  }

  /// Sends SIP ACK packet to OpenSIPS after 200 OK answer (RFC 3261 Compliant)
  void _sendAckPacket([String? responseMessage]) async {
    if (_activeOrder == null) return;
    final formattedPhone = ItSkySipConfig.formatOutboundDialString(_activeOrder!.customerPhone);
    final localIp = await _getLocalIpAddress();
    final rtpPort = _socket?.port ?? 5060;
    final viaBranch = 'z9hG4bK-nova-${DateTime.now().millisecondsSinceEpoch}';

    String toHeader = '<sip:$formattedPhone@${ItSkySipConfig.domain}>';
    if (responseMessage != null) {
      final toMatch = RegExp(r'To: ([^\r\n]+)', caseSensitive: false).firstMatch(responseMessage);
      if (toMatch != null) {
        toHeader = toMatch.group(1)!;
      }
    }

    final StringBuffer sipMsg = StringBuffer();
    sipMsg.writeln('ACK sip:$formattedPhone@${ItSkySipConfig.domain} SIP/2.0');
    sipMsg.writeln('Via: SIP/2.0/UDP $localIp:$rtpPort;rport;branch=$viaBranch');
    sipMsg.writeln('Max-Forwards: 70');
    sipMsg.writeln('From: <sip:${ItSkySipConfig.username}@${ItSkySipConfig.domain}>;tag=${_activeFromTag ?? "nova"}');
    sipMsg.writeln('To: $toHeader');
    sipMsg.writeln('Call-ID: ${_activeCallId ?? "novasuite-call"}');
    sipMsg.writeln('CSeq: $_cseq ACK');
    sipMsg.writeln('Content-Length: 0');
    sipMsg.writeln('');

    print('📡 [UDP SIP] Outbound Matched ACK sent for $formattedPhone (To: $toHeader)');
    final bytes = utf8.encode(sipMsg.toString());
    _socket?.send(bytes, InternetAddress(ItSkySipConfig.providerSipHost), ItSkySipConfig.providerSipPort);
  }

  /// Responds SIP 200 OK to incoming BYE request to terminate transaction cleanly
  void _sendBye200OKResponse(String byeMessage) {
    final viaMatch = RegExp(r'Via: ([^\r\n]+)').firstMatch(byeMessage);
    final fromMatch = RegExp(r'From: ([^\r\n]+)').firstMatch(byeMessage);
    final toMatch = RegExp(r'To: ([^\r\n]+)').firstMatch(byeMessage);
    final callIdMatch = RegExp(r'Call-ID: ([^\r\n]+)').firstMatch(byeMessage);
    final cseqMatch = RegExp(r'CSeq: ([^\r\n]+)').firstMatch(byeMessage);

    final StringBuffer sipMsg = StringBuffer();
    sipMsg.writeln('SIP/2.0 200 OK');
    if (viaMatch != null) sipMsg.writeln('Via: ${viaMatch.group(1)}');
    if (fromMatch != null) sipMsg.writeln('From: ${fromMatch.group(1)}');
    if (toMatch != null) sipMsg.writeln('To: ${toMatch.group(1)}');
    if (callIdMatch != null) sipMsg.writeln('Call-ID: ${callIdMatch.group(1)}');
    if (cseqMatch != null) sipMsg.writeln('CSeq: ${cseqMatch.group(1)}');
    sipMsg.writeln('User-Agent: MicroSIP/3.21.3');
    sipMsg.writeln('Content-Length: 0');
    sipMsg.writeln('');

    final bytes = utf8.encode(sipMsg.toString());
    _socket?.send(bytes, InternetAddress(ItSkySipConfig.providerSipHost), ItSkySipConfig.providerSipPort);
  }

  /// Handles 401 Unauthorized Digest MD5 Challenge from OpenSIPS (with qop=auth support)
  void _handle401Challenge(String message) {
    final nonceMatch = RegExp(r'nonce="([^"]+)"').firstMatch(message);
    if (nonceMatch != null) {
      _lastNonce = nonceMatch.group(1);
      final realmMatch = RegExp(r'realm="([^"]+)"').firstMatch(message) ?? RegExp(r'realm=([^\s,]+)').firstMatch(message);
      final qopMatch = RegExp(r'qop="([^"]+)"').firstMatch(message);

      final realm = realmMatch?.group(1) ?? ItSkySipConfig.domain;
      final qop = qopMatch?.group(1);
      final uri = 'sip:${ItSkySipConfig.domain}';
      final cnonce = 'nova${DateTime.now().millisecondsSinceEpoch}';
      const nc = '00000001';

      final ha1 = md5.convert(utf8.encode('${ItSkySipConfig.username}:$realm:${ItSkySipConfig.password}')).toString();
      final ha2 = md5.convert(utf8.encode('REGISTER:$uri')).toString();
      
      String responseHash;
      String authHeader;

      if (qop == 'auth' || qop == 'auth,auth-int') {
        responseHash = md5.convert(utf8.encode('$ha1:$_lastNonce:$nc:$cnonce:auth:$ha2')).toString();
        authHeader = 'Digest username="${ItSkySipConfig.username}", realm="$realm", nonce="$_lastNonce", uri="$uri", response="$responseHash", cnonce="$cnonce", nc=$nc, qop=auth, algorithm=MD5';
      } else {
        responseHash = md5.convert(utf8.encode('$ha1:$_lastNonce:$ha2')).toString();
        authHeader = 'Digest username="${ItSkySipConfig.username}", realm="$realm", nonce="$_lastNonce", uri="$uri", response="$responseHash", algorithm=MD5';
      }

      _sendRegisterPacket(authHeader);
    }
  }

  /// Handles 407 Proxy Authentication Required Digest MD5 Challenge from OpenSIPS for INVITE calls
  void _handle407Challenge(String message) {
    if (_callState == UdpCallState.ended || _callState == UdpCallState.disconnected || _callState == UdpCallState.idle) {
      print('⏹️ [UDP SIP] Call was cancelled before 407 challenge completed. Aborting 2nd INVITE.');
      return;
    }
    final nonceMatch = RegExp(r'nonce="([^"]+)"').firstMatch(message);
    if (nonceMatch != null && _activeOrder != null) {
      final nonce = nonceMatch.group(1)!;
      final realmMatch = RegExp(r'realm="([^"]+)"').firstMatch(message) ?? RegExp(r'realm=([^\s,]+)').firstMatch(message);
      final qopMatch = RegExp(r'qop="([^"]+)"').firstMatch(message);

      final realm = realmMatch?.group(1) ?? ItSkySipConfig.domain;
      final qop = qopMatch?.group(1);
      final formattedPhone = ItSkySipConfig.formatOutboundDialString(_activeOrder!.customerPhone);
      final uri = 'sip:$formattedPhone@${ItSkySipConfig.domain}';
      final cnonce = 'nova${DateTime.now().millisecondsSinceEpoch}';
      const nc = '00000001';

      final ha1 = md5.convert(utf8.encode('${ItSkySipConfig.username}:$realm:${ItSkySipConfig.password}')).toString();
      final ha2 = md5.convert(utf8.encode('INVITE:$uri')).toString();
      
      String responseHash;
      String authHeader;

      if (qop == 'auth' || qop == 'auth,auth-int') {
        responseHash = md5.convert(utf8.encode('$ha1:$nonce:$nc:$cnonce:auth:$ha2')).toString();
        authHeader = 'username="${ItSkySipConfig.username}", realm="$realm", nonce="$nonce", uri="$uri", response="$responseHash", cnonce="$cnonce", nc=$nc, qop=auth, algorithm=MD5';
      } else {
        responseHash = md5.convert(utf8.encode('$ha1:$nonce:$ha2')).toString();
        authHeader = 'username="${ItSkySipConfig.username}", realm="$realm", nonce="$nonce", uri="$uri", response="$responseHash", algorithm=MD5';
      }

      _sendInvitePacket(authHeader);
    }
  }

  String? _activeCallId;
  String? _activeFromTag;
  bool _hasEarlyMedia = false;

  /// Initiates an outbound UDP SIP INVITE call to customer phone number
  Future<void> initiateCall(OrderModel order) async {
    _activeOrder = order;
    _callDuration = 0;
    _hasEarlyMedia = false;
    _activeCallId = 'novasuite-call-${DateTime.now().millisecondsSinceEpoch}@${_socket?.address.address ?? '127.0.0.1'}';
    _activeFromTag = 'nova${DateTime.now().millisecondsSinceEpoch}';
    _notifyCallState(UdpCallState.connecting);

    final formattedPhone = ItSkySipConfig.formatOutboundDialString(order.customerPhone);
    print('📞 [UDP SIP] Initiating Call to Customer Phone: $formattedPhone (${order.customerName})...');

    if (_status != UdpSipStatus.registered) {
      final registered = await registerUdpTrunk();
      if (!registered) {
        print('❌ [UDP SIP] Registration failed. Cannot place call.');
        _notifyCallState(UdpCallState.disconnected);
        return;
      }
    }

    _sendInvitePacket();
  }

  Future<String> _getLocalIpAddress() async {
    try {
      final interfaces = await NetworkInterface.list(type: InternetAddressType.IPv4, includeLinkLocal: false);
      for (final interface in interfaces) {
        final name = interface.name.toLowerCase();
        if (name.contains('vethernet') || name.contains('virtual') || name.contains('vmnet') || name.contains('wsl')) {
          continue;
        }
        for (final addr in interface.addresses) {
          if (!addr.isLoopback && !addr.address.startsWith('192.168.137.')) {
            return addr.address;
          }
        }
      }
    } catch (_) {}
    return '127.0.0.1';
  }

  void _sendInvitePacket([String? proxyAuthHeader]) async {
    if (_activeOrder == null || _callState == UdpCallState.ended || _callState == UdpCallState.disconnected || _callState == UdpCallState.idle) {
      print('⏹️ [UDP SIP] Call state is no longer active. Aborting outbound INVITE.');
      return;
    }
    _cseq++;
    final formattedPhone = ItSkySipConfig.formatOutboundDialString(_activeOrder!.customerPhone);
    final callId = _activeCallId ?? 'novasuite-call-${DateTime.now().millisecondsSinceEpoch}@127.0.0.1';
    final fromTag = _activeFromTag ?? 'nova${DateTime.now().millisecondsSinceEpoch}';
    final viaBranch = 'z9hG4bK-nova-${DateTime.now().millisecondsSinceEpoch}';
    final localIp = await _getLocalIpAddress();
    final rtpPort = _socket?.port ?? 5060;

    final StringBuffer sipMsg = StringBuffer();
    sipMsg.writeln('INVITE sip:$formattedPhone@${ItSkySipConfig.domain} SIP/2.0');
    sipMsg.writeln('Via: SIP/2.0/UDP $localIp:$rtpPort;rport;branch=$viaBranch');
    sipMsg.writeln('Max-Forwards: 70');
    sipMsg.writeln('From: <sip:${ItSkySipConfig.username}@${ItSkySipConfig.domain}>;tag=$fromTag');
    sipMsg.writeln('To: <sip:$formattedPhone@${ItSkySipConfig.domain}>');
    sipMsg.writeln('Call-ID: $callId');
    sipMsg.writeln('CSeq: $_cseq INVITE');
    sipMsg.writeln('Contact: <sip:${ItSkySipConfig.username}@$localIp:$rtpPort>');
    if (proxyAuthHeader != null) {
      sipMsg.writeln('Proxy-Authorization: Digest $proxyAuthHeader');
    }
    sipMsg.writeln('User-Agent: MicroSIP/3.21.3');
    sipMsg.writeln('Content-Type: application/sdp');

    // Real Bound LAN Port SDP 2-Way Audio Offer
    final sdp = 'v=0\r\no=- ${DateTime.now().millisecondsSinceEpoch} 1 IN IP4 $localIp\r\ns=NovaSuite Voice\r\nc=IN IP4 $localIp\r\nt=0 0\r\nm=audio $rtpPort RTP/AVP 0 8 101\r\na=rtpmap:0 PCMU/8000\r\na=rtpmap:8 PCMA/8000\r\na=rtpmap:101 telephone-event/8000\r\na=sendrecv\r\n';
    sipMsg.writeln('Content-Length: ${sdp.length}');
    sipMsg.writeln('');
    sipMsg.write(sdp);

    print('📡 [UDP SIP] Outbound INVITE packet sent for $formattedPhone (Call-ID: $callId, CSeq: $_cseq, Local IP: $localIp:$rtpPort)');
    final bytes = utf8.encode(sipMsg.toString());
    _socket?.send(bytes, InternetAddress(ItSkySipConfig.providerSipHost), ItSkySipConfig.providerSipPort);
  }

  void _startTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _notifyDuration(_callDuration + 1);
    });
  }

  void _sendHangupPacket(String method, String formattedPhone, String viaBranch) {
    _cseq++;
    final bool isInbound = _incomingCallerNumber != null && _activeOrder == null;

    final fromHeader = isInbound
        ? 'From: <sip:${ItSkySipConfig.username}@${ItSkySipConfig.domain}>;tag=$_activeToTag'
        : 'From: <sip:${ItSkySipConfig.username}@${ItSkySipConfig.domain}>;tag=${_activeFromTag ?? "nova"}';

    final toHeader = isInbound
        ? 'To: <sip:$formattedPhone@${ItSkySipConfig.domain}>;tag=$_activeFromTag'
        : (_activeToTag != null ? 'To: <sip:$formattedPhone@${ItSkySipConfig.domain}>;tag=$_activeToTag' : 'To: <sip:$formattedPhone@${ItSkySipConfig.domain}>');

    String requestUri;
    if (isInbound && _remoteContactUri != null && _remoteContactUri!.startsWith('sip:')) {
      requestUri = _remoteContactUri!;
    } else {
      requestUri = 'sip:$formattedPhone@${ItSkySipConfig.domain}';
    }

    final StringBuffer sipMsg = StringBuffer();
    sipMsg.writeln('$method $requestUri SIP/2.0');
    sipMsg.writeln('Via: SIP/2.0/UDP ${_socket?.address.address ?? '0.0.0.0'}:${_socket?.port ?? 5060};rport;branch=$viaBranch');
    sipMsg.writeln('Max-Forwards: 70');
    sipMsg.writeln(fromHeader);
    sipMsg.writeln(toHeader);
    sipMsg.writeln('Call-ID: $_activeCallId');
    sipMsg.writeln('CSeq: $_cseq $method');
    sipMsg.writeln('User-Agent: MicroSIP/3.21.3');
    sipMsg.writeln('Content-Length: 0');
    sipMsg.writeln('');

    print('⏹️ [UDP SIP] Sent $method hangup packet for $formattedPhone (Target: $requestUri, $fromHeader, $toHeader)');
    final bytes = utf8.encode(sipMsg.toString());
    _socket?.send(bytes, InternetAddress(ItSkySipConfig.providerSipHost), ItSkySipConfig.providerSipPort);
  }

  void endCall() {
    print('⏹️ [UDP SIP] Hanging up call session cleanly...');
    _durationTimer?.cancel();

    final currentCallState = _callState;
    final targetPhone = _activeOrder?.customerPhone ?? _incomingCallerNumber;
    final activeCallId = _activeCallId;

    _notifyCallState(UdpCallState.ended);

    if (targetPhone != null && activeCallId != null) {
      final formattedPhone = ItSkySipConfig.formatOutboundDialString(targetPhone);
      final viaBranch = 'z9hG4bK-nova-${DateTime.now().millisecondsSinceEpoch}';
      
      if (currentCallState == UdpCallState.active) {
        _sendHangupPacket('BYE', formattedPhone, viaBranch);
      } else {
        _sendHangupPacket('CANCEL', formattedPhone, viaBranch);
      }
    }

    // Finalize 2-way call audio recording & upload asynchronously to cloud storage
    WaveCallRecorder().stopRecording(durationSeconds: _callDuration).then((recording) {
      if (recording != null) {
        final localFile = File(recording.localFilePath);
        SupabaseMediaStorageService().uploadCallRecording(
          file: localFile,
          callId: recording.callId,
          customerPhone: targetPhone ?? '000',
        );
      }
    });

    _stopRingbackTone();
    NovaWinmmAudioDriver().closeAudioDevice();

    Timer(const Duration(milliseconds: 300), () {
      _notifyCallState(UdpCallState.disconnected);
    });
  }

  Timer? _ringbackTimer;

  void _startRingbackTone() {
    _stopRingbackTone();
    // Play initial ringback tone immediately
    _playBeepTone();
    _ringbackTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_callState == UdpCallState.ringing || _callState == UdpCallState.connecting) {
        _playBeepTone();
      } else {
        timer.cancel();
      }
    });
  }

  void _stopRingbackTone() {
    _ringbackTimer?.cancel();
    _ringbackTimer = null;
  }

  void _playBeepTone() {
    if (!kIsWeb && Platform.isWindows) {
      NovaWinmmAudioDriver().playPstnRingbackTone();
    }
  }

  int _rtpPacketCount = 0;

  void _processIncomingRtpAudioPayload(Uint8List rtpData) {
    if (_ringbackTimer != null) {
      _stopRingbackTone();
    }
    _rtpPacketCount++;
    if (_rtpPacketCount % 50 == 1) {
      print('🎧 [Windows Native Audio Stream] Playing G.711 RTP Audio Packet #$_rtpPacketCount (${rtpData.length} bytes) to sound card...');
    }
    // Record incoming customer voice audio for 2-way call QA recording
    if (rtpData.length > 12) {
      WaveCallRecorder().recordCustomerIncomingFrame(rtpData.sublist(12));
    }
    // Stream live G.711 u-law RTP audio bytes directly into Windows WASAPI sound card
    NovaWinmmAudioDriver().playG711RtpPayload(rtpData);
  }

  int? _remoteRtpPort;
  String? _remoteRtpHost;

  void _parseSdpAnswer(String sdpMessage) {
    final mAudioMatch = RegExp(r'm=audio (\d+)', caseSensitive: false).firstMatch(sdpMessage);
    if (mAudioMatch != null) {
      _remoteRtpPort = int.tryParse(mAudioMatch.group(1)!);
    }
    final cIpMatch = RegExp(r'c=IN IP4 ([^\s\r\n]+)', caseSensitive: false).firstMatch(sdpMessage);
    if (cIpMatch != null) {
      _remoteRtpHost = cIpMatch.group(1);
    }
    print('🎵 [RTP Media Setup] Remote Media Gateway Target: ${_remoteRtpHost ?? ItSkySipConfig.providerSipHost}:${_remoteRtpPort ?? 8000}');
  }

  void _startEarlyMediaSession() {
    NovaWinmmAudioDriver().openAudioDevice();
    _sendRtpSilenceFrame();
  }

  void _startRtpAudioSession() {
    NovaWinmmAudioDriver().openAudioDevice();
    
    // Start 2-way audio call recording
    WaveCallRecorder().startRecording(
      callId: _activeCallId ?? 'call_${DateTime.now().millisecondsSinceEpoch}',
      customerPhone: _activeOrder?.customerPhone ?? _incomingCallerNumber ?? '000',
    );

    // Send initial single RTP silence frame to open NAT pinhole
    _sendRtpSilenceFrame();

    // Start single continuous stream of live headset microphone audio
    NovaWinmmAudioDriver().startMicrophoneCapture((micFrame) {
      if (_callState == UdpCallState.active) {
        _sendRtpAudioFrame(micFrame);
      }
    });
  }

  void _sendRtpAudioFrame(Uint8List micPayload) {
    if (_remoteRtpPort == null || _socket == null) return;

    // Record agent microphone voice audio for 2-way call QA recording
    WaveCallRecorder().recordAgentMicrophoneFrame(micPayload);

    final rtpPacket = Uint8List(12 + micPayload.length);
    rtpPacket[0] = 0x80; // RTP v2
    rtpPacket[1] = 0x00; // Payload type 0 (PCMU)
    final seq = (_cseq++) & 0xFFFF;
    rtpPacket[2] = (seq >> 8) & 0xFF;
    rtpPacket[3] = seq & 0xFF;

    rtpPacket.setRange(12, 12 + micPayload.length, micPayload);

    final targetHost = _remoteRtpHost ?? ItSkySipConfig.providerSipHost;
    _socket?.send(rtpPacket, InternetAddress(targetHost), _remoteRtpPort!);
  }

  void _sendRtpSilenceFrame() {
    if (_remoteRtpPort == null || _socket == null) return;

    // Build 12-byte standard RTP v2 Header + 160-byte G.711 u-law payload
    final rtpPacket = Uint8List(172);
    rtpPacket[0] = 0x80; // RTP v2
    rtpPacket[1] = 0x00; // Payload type 0 (PCMU)
    final seq = (_cseq++) & 0xFFFF;
    rtpPacket[2] = (seq >> 8) & 0xFF;
    rtpPacket[3] = seq & 0xFF;
    
    // G.711 u-law neutral 0-amplitude voice byte is 0x7F (RFC 3551 compliant)
    for (int i = 12; i < 172; i++) {
      rtpPacket[i] = 0x7F;
    }

    final targetHost = _remoteRtpHost ?? ItSkySipConfig.providerSipHost;
    _socket?.send(rtpPacket, InternetAddress(targetHost), _remoteRtpPort!);
  }
}
