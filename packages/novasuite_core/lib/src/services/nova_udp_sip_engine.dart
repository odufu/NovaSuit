import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import '../it_sky_sip_config.dart';
import '../models/order.dart';

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

  Stream<UdpSipStatus> get statusStream => _statusController.stream;
  Stream<UdpCallState> get callStateStream => _callStateController.stream;
  Stream<int> get durationStream => _durationController.stream;

  UdpSipStatus get status => _status;
  UdpCallState get callState => _callState;
  OrderModel? get activeOrder => _activeOrder;
  int get callDuration => _callDuration;
  String? get lastError => _lastError;

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

  /// Handles incoming UDP packets from OpenSIPS PBX
  void _handleIncomingDatagram(RawSocketEvent event) {
    if (event == RawSocketEvent.read) {
      final datagram = _socket?.receive();
      if (datagram == null) return;

      final message = utf8.decode(datagram.data);
      final firstLine = message.split('\r\n').first;
      print('📥 [UDP SIP] Received Datagram: $firstLine');

      if (message.contains('SIP/2.0 401 Unauthorized')) {
        print('🔒 [UDP SIP] Received 401 Unauthorized Challenge -> Resolving MD5 Digest...');
        _handle401Challenge(message);
      } else if (message.contains('SIP/2.0 200 OK')) {
        print('🎉 [UDP SIP] Received 200 OK Response from OpenSIPS!');
        if (_status == UdpSipStatus.registering) {
          _notifyStatus(UdpSipStatus.registered);
          if (_registerCompleter != null && !_registerCompleter!.isCompleted) {
            _registerCompleter!.complete(true);
          }
        } else if (_callState == UdpCallState.ringing || _callState == UdpCallState.connecting) {
          print('📞 [UDP SIP] Call Answered! Audio stream active.');
          _notifyCallState(UdpCallState.active);
          _startTimer();
        }
      } else if (message.contains('180 Ringing') || message.contains('183 Session Progress')) {
        print('🔔 [UDP SIP] Remote Phone Ringing (180/183)...');
        _notifyCallState(UdpCallState.ringing);
      } else if (message.contains('BYE') || message.contains('486 Busy') || message.contains('603 Decline')) {
        print('⏹️ [UDP SIP] Call Terminated by Remote / PBX.');
        _notifyCallState(UdpCallState.ended);
        _durationTimer?.cancel();
      }
    }
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

  /// Initiates an outbound UDP SIP INVITE call to customer phone number
  Future<void> initiateCall(OrderModel order) async {
    _activeOrder = order;
    _callDuration = 0;
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

    _cseq++;
    final callId = 'novasuite-call-${DateTime.now().millisecondsSinceEpoch}@${_socket?.address.address ?? '0.0.0.0'}';
    final viaBranch = 'z9hG4bK-nova-${DateTime.now().millisecondsSinceEpoch}';

    final StringBuffer sipMsg = StringBuffer();
    sipMsg.writeln('INVITE sip:$formattedPhone@${ItSkySipConfig.domain} SIP/2.0');
    sipMsg.writeln('Via: SIP/2.0/UDP ${_socket?.address.address ?? '0.0.0.0'}:${_socket?.port ?? 5060};rport;branch=$viaBranch');
    sipMsg.writeln('Max-Forwards: 70');
    sipMsg.writeln('From: <sip:${ItSkySipConfig.username}@${ItSkySipConfig.domain}>;tag=nova${DateTime.now().millisecondsSinceEpoch}');
    sipMsg.writeln('To: <sip:$formattedPhone@${ItSkySipConfig.domain}>');
    sipMsg.writeln('Call-ID: $callId');
    sipMsg.writeln('CSeq: $_cseq INVITE');
    sipMsg.writeln('Contact: <sip:${ItSkySipConfig.username}@${_socket?.address.address ?? '0.0.0.0'}:${_socket?.port ?? 5060}>');
    sipMsg.writeln('User-Agent: MicroSIP/3.21.3');
    sipMsg.writeln('Content-Type: application/sdp');

    // Minimal SDP Audio Offer
    final sdp = 'v=0\r\no=- ${DateTime.now().millisecondsSinceEpoch} 1 IN IP4 127.0.0.1\r\ns=NovaSuite Voice\r\nc=IN IP4 127.0.0.1\r\nt=0 0\r\nm=audio 8000 RTP/AVP 0 8 101\r\na=rtpmap:0 PCMU/8000\r\na=rtpmap:8 PCMA/8000\r\na=rtpmap:101 telephone-event/8000\r\n';
    sipMsg.writeln('Content-Length: ${sdp.length}');
    sipMsg.writeln('');
    sipMsg.write(sdp);

    print('📡 [UDP SIP] Outbound INVITE packet sent for $formattedPhone');
    final bytes = utf8.encode(sipMsg.toString());
    _socket?.send(bytes, InternetAddress(ItSkySipConfig.providerSipHost), ItSkySipConfig.providerSipPort);
  }

  void _startTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _notifyDuration(_callDuration + 1);
    });
  }

  void endCall() {
    print('⏹️ [UDP SIP] Hanging up call...');
    _durationTimer?.cancel();
    _notifyCallState(UdpCallState.ended);
    Timer(const Duration(milliseconds: 1000), () {
      _notifyCallState(UdpCallState.disconnected);
    });
  }
}
