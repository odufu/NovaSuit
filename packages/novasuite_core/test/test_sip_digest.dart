import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';

void main() async {
  print('================================================================');
  print('💻 Testing Complete 2-Step SIP Digest Auth Exchange (07003100077)');
  print('================================================================');

  const sipServerIp = '95.217.244.97';
  const sipPort = 5060;
  const username = '07003100077';
  const password = 'C)Jz2(yC';
  const domain = '07003100077.astpp.itskysolutions.com';

  final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
  print('📡 Bound Windows UDP Socket on Port: ${socket.port}');

  final callId = 'win-auth-${DateTime.now().millisecondsSinceEpoch}@127.0.0.1';
  final tag = 'tag-${DateTime.now().millisecondsSinceEpoch}';

  // Step 1: Initial unauthenticated REGISTER
  final reg1 = 
    'REGISTER sip:$domain SIP/2.0\r\n'
    'Via: SIP/2.0/UDP 127.0.0.1:${socket.port};rport;branch=z9hG4bK-step1-${DateTime.now().millisecondsSinceEpoch}\r\n'
    'From: <sip:$username@$domain>;tag=$tag\r\n'
    'To: <sip:$username@$domain>\r\n'
    'Call-ID: $callId\r\n'
    'CSeq: 1 REGISTER\r\n'
    'Contact: <sip:$username@127.0.0.1:${socket.port}>\r\n'
    'Max-Forwards: 70\r\n'
    'User-Agent: NovaCare-WindowsDesktop/1.0 (MicroSIP-Parity)\r\n'
    'Expires: 3600\r\n'
    'Content-Length: 0\r\n\r\n';

  print('\n📡 Step 1: Sending initial REGISTER...');
  socket.send(utf8.encode(reg1), InternetAddress(sipServerIp), sipPort);

  int step = 1;

  socket.listen((RawSocketEvent event) {
    if (event == RawSocketEvent.read) {
      final datagram = socket.receive();
      if (datagram == null) return;

      final response = utf8.decode(datagram.data);
      final lines = response.split('\r\n');
      final statusLine = lines.first;

      print('\n📥 Response: $statusLine');

      if ((statusLine.contains('401') || statusLine.contains('407')) && step == 1) {
        step = 2;
        print('🔒 Step 2: Extracting Digest Challenge Nonce & Realm...');
        
        final nonceMatch = RegExp(r'nonce="([^"]+)"').firstMatch(response);
        final realmMatch = RegExp(r'realm="([^"]+)"').firstMatch(response) ?? RegExp(r'realm=([^\s,]+)').firstMatch(response);
        final qopMatch = RegExp(r'qop="([^"]+)"').firstMatch(response);

        final nonce = nonceMatch?.group(1) ?? '';
        final realm = realmMatch?.group(1) ?? domain;
        final qop = qopMatch?.group(1);
        final uri = 'sip:$domain';
        final cnonce = 'cnonce${DateTime.now().millisecondsSinceEpoch}';
        const nc = '00000001';

        print('   👉 Nonce: $nonce');
        print('   👉 Realm: $realm');
        print('   👉 Qop: $qop');

        final ha1 = md5.convert(utf8.encode('$username:$realm:$password')).toString();
        final ha2 = md5.convert(utf8.encode('REGISTER:$uri')).toString();
        
        String responseHash;
        String authHeader;

        if (qop == 'auth' || qop == 'auth,auth-int') {
          responseHash = md5.convert(utf8.encode('$ha1:$nonce:$nc:$cnonce:auth:$ha2')).toString();
          authHeader = 'Authorization: Digest username="$username", realm="$realm", nonce="$nonce", uri="$uri", response="$responseHash", cnonce="$cnonce", nc=$nc, qop=auth, algorithm=MD5';
        } else {
          responseHash = md5.convert(utf8.encode('$ha1:$nonce:$ha2')).toString();
          authHeader = 'Authorization: Digest username="$username", realm="$realm", nonce="$nonce", uri="$uri", response="$responseHash", algorithm=MD5';
        }

        final reg2 = 
          'REGISTER sip:$domain SIP/2.0\r\n'
          'Via: SIP/2.0/UDP 127.0.0.1:${socket.port};rport;branch=z9hG4bK-step2-${DateTime.now().millisecondsSinceEpoch}\r\n'
          'From: <sip:$username@$domain>;tag=$tag\r\n'
          'To: <sip:$username@$domain>\r\n'
          'Call-ID: $callId\r\n'
          'CSeq: 2 REGISTER\r\n'
          'Contact: <sip:$username@127.0.0.1:${socket.port}>\r\n'
          '$authHeader\r\n'
          'Max-Forwards: 70\r\n'
          'User-Agent: NovaCare-WindowsDesktop/1.0 (MicroSIP-Parity)\r\n'
          'Expires: 3600\r\n'
          'Content-Length: 0\r\n\r\n';

        print('📡 Sending Step 2 Authenticated REGISTER Packet...');
        socket.send(utf8.encode(reg2), InternetAddress(sipServerIp), sipPort);
      } else if (statusLine.contains('200')) {
        print('\n🎉🎉🎉 200 OK! SIP REGISTRATION SUCCESSFUL ON WINDOWS DESKTOP! 🎉🎉🎉');
        print('   Authentication verified 100%! Credentials ($username / $password) accepted!');
        socket.close();
        exit(0);
      }
    }
  });

  await Future.delayed(const Duration(seconds: 5));
  print('\n================================================================');
  print('🏁 SIP Digest Auth Test Completed.');
  print('================================================================');
  exit(0);
}
