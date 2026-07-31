import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

void main() async {
  print('=====================================================');
  print('🚀 Testing Direct UDP SIP Interconnect to OpenSIPS 3.3.3 (qop=auth)');
  print('=====================================================');

  const sipHost = '95.217.244.97';
  const sipPort = 5060;
  const sipDomain = '07003100077.astpp.itskysolutions.com';
  const username = '07003100077';
  const password = 'C)Jz2(yC';

  final targetAddress = InternetAddress(sipHost);

  try {
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    print('✅ Bound local UDP socket at ${socket.address.address}:${socket.port}');

    int cseq = 100;
    String callId = 'novasuite-test-${DateTime.now().millisecondsSinceEpoch}@${socket.address.address}';
    String viaBranch = 'z9hG4bK-nova-${DateTime.now().millisecondsSinceEpoch}';

    // Step 1: Send Initial Unauthenticated REGISTER
    String registerMsg = _buildRegister(
      username: username,
      domain: sipDomain,
      localIp: socket.address.address,
      localPort: socket.port,
      cseq: cseq,
      callId: callId,
      viaBranch: viaBranch,
    );

    print('\n📤 Sending initial SIP REGISTER to $sipHost:$sipPort...');
    socket.send(utf8.encode(registerMsg), targetAddress, sipPort);

    // Listen for responses
    socket.listen((event) {
      if (event == RawSocketEvent.read) {
        final datagram = socket.receive();
        if (datagram != null) {
          final responseText = utf8.decode(datagram.data);
          print('\n📥 Received SIP Response from ${datagram.address.address}:${datagram.port}:');
          print('-----------------------------------------------------');
          print(responseText);
          print('-----------------------------------------------------');

          if (responseText.contains('SIP/2.0 401 Unauthorized')) {
            print('\n🛡️ 401 Challenge Received! Computing qop=auth Digest MD5 Response...');
            final nonceMatch = RegExp(r'nonce="([^"]+)"').firstMatch(responseText);
            final realmMatch = RegExp(r'realm="([^"]+)"').firstMatch(responseText) ?? RegExp(r'realm=([^\s,]+)').firstMatch(responseText);
            final qopMatch = RegExp(r'qop="([^"]+)"').firstMatch(responseText);

            if (nonceMatch != null) {
              final nonce = nonceMatch.group(1)!;
              final realm = realmMatch?.group(1) ?? sipDomain;
              final qop = qopMatch?.group(1);

              cseq++;
              viaBranch = 'z9hG4bK-nova-auth-${DateTime.now().millisecondsSinceEpoch}';
              
              final uri = 'sip:$sipDomain';
              final cnonce = 'nova${DateTime.now().millisecondsSinceEpoch}';
              const nc = '00000001';

              final ha1 = md5.convert(utf8.encode('$username:$realm:$password')).toString();
              final ha2 = md5.convert(utf8.encode('REGISTER:$uri')).toString();
              
              String responseHash;
              String authHeader;

              if (qop == 'auth' || qop == 'auth,auth-int') {
                responseHash = md5.convert(utf8.encode('$ha1:$nonce:$nc:$cnonce:auth:$ha2')).toString();
                authHeader = 'Digest username="$username", realm="$realm", nonce="$nonce", uri="$uri", response="$responseHash", cnonce="$cnonce", nc=$nc, qop=auth, algorithm=MD5';
              } else {
                responseHash = md5.convert(utf8.encode('$ha1:$nonce:$ha2')).toString();
                authHeader = 'Digest username="$username", realm="$realm", nonce="$nonce", uri="$uri", response="$responseHash", algorithm=MD5';
              }

              final authRegisterMsg = _buildRegister(
                username: username,
                domain: sipDomain,
                localIp: socket.address.address,
                localPort: socket.port,
                cseq: cseq,
                callId: callId,
                viaBranch: viaBranch,
                authHeader: authHeader,
              );

              print('\n📤 Sending Authenticated SIP REGISTER (with Digest Response: $responseHash)...');
              socket.send(utf8.encode(authRegisterMsg), targetAddress, sipPort);
            }
          } else if (responseText.contains('200 OK')) {
            print('\n🎉🎉🎉 SUCCESS! SIP Trunk 07003100077 Authenticated & Registered with OpenSIPS/ASTPP! 🎉🎉🎉');
            socket.close();
            exit(0);
          }
        }
      }
    });

    // Timeout safety
    Timer(const Duration(seconds: 10), () {
      print('\n⏳ Test Completed (10s elapsed). Closing UDP socket.');
      socket.close();
      exit(0);
    });
  } catch (e, st) {
    print('❌ UDP Connection Error: $e');
    print(st);
  }
}

String _buildRegister({
  required String username,
  required String domain,
  required String localIp,
  required int localPort,
  required int cseq,
  required String callId,
  required String viaBranch,
  String? authHeader,
}) {
  final buf = StringBuffer();
  buf.writeln('REGISTER sip:$domain SIP/2.0');
  buf.writeln('Via: SIP/2.0/UDP $localIp:$localPort;rport;branch=$viaBranch');
  buf.writeln('Max-Forwards: 70');
  buf.writeln('From: <sip:$username@$domain>;tag=nova${DateTime.now().millisecondsSinceEpoch}');
  buf.writeln('To: <sip:$username@$domain>');
  buf.writeln('Call-ID: $callId');
  buf.writeln('CSeq: $cseq REGISTER');
  buf.writeln('Contact: <sip:$username@$localIp:$localPort>');
  buf.writeln('User-Agent: MicroSIP/3.21.3');
  buf.writeln('Expires: 300');
  if (authHeader != null) {
    buf.writeln('Authorization: $authHeader');
  }
  buf.writeln('Content-Length: 0');
  buf.writeln('');
  return buf.toString();
}
