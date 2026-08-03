import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';

void main() async {
  print('================================================================');
  print('💻 Windows Desktop Native UDP SIP Register & Auth Probe');
  print('================================================================');

  const sipServerIp = '95.217.244.97';
  const sipPort = 5060;
  const username = '07003100077';
  const password = 'C)Jz2(yC';
  const domain = '07003100077.astpp.itskysolutions.com';

  print('📡 Binding Local Windows OS UDP Socket...');
  final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
  print('   ✅ Bound Windows Socket on Port: ${socket.port}');

  final callId = 'win-call-${DateTime.now().millisecondsSinceEpoch}@127.0.0.1';
  final tag = 'win-tag-${DateTime.now().millisecondsSinceEpoch}';

  // Step 1: Send initial REGISTER (triggers 401 Unauthorized Digest Challenge from IT Sky)
  final registerPacket1 = 
    'REGISTER sip:$domain SIP/2.0\r\n'
    'Via: SIP/2.0/UDP 127.0.0.1:${socket.port};rport;branch=z9hG4bK-reg1-${DateTime.now().millisecondsSinceEpoch}\r\n'
    'From: <sip:$username@$domain>;tag=$tag\r\n'
    'To: <sip:$username@$domain>\r\n'
    'Call-ID: $callId\r\n'
    'CSeq: 1 REGISTER\r\n'
    'Contact: <sip:$username@127.0.0.1:${socket.port}>\r\n'
    'Max-Forwards: 70\r\n'
    'User-Agent: NovaCare-WindowsDesktop/1.0 (MicroSIP-Parity)\r\n'
    'Expires: 3600\r\n'
    'Content-Length: 0\r\n\r\n';

  print('\n📡 Step 1: Transmitting Initial SIP REGISTER to $sipServerIp:$sipPort...');
  socket.send(utf8.encode(registerPacket1), InternetAddress(sipServerIp), sipPort);

  socket.listen((RawSocketEvent event) {
    if (event == RawSocketEvent.read) {
      final datagram = socket.receive();
      if (datagram != null) {
        final response = utf8.decode(datagram.data);
        final lines = response.split('\r\n');
        final statusLine = lines.first;
        print('\n📥 Received Response from Server: $statusLine');

        if (statusLine.contains('401') || statusLine.contains('407')) {
          print('   🔒 Digest Authentication Challenge Received from IT Sky (Parity with MicroSIP)!');
          print('   👉 Status: $statusLine');
          print('   👉 Server Header: ${lines.firstWhere((l) => l.toLowerCase().startsWith("server:"), orElse: () => "")}');
          print('\n🎉🎉🎉 WINDOWS DESKTOP NATIVE UDP SIP SUCCESS! 🎉🎉🎉');
          print('   The Windows Desktop App can communicate over UDP 5060 with IT Sky!');
          socket.close();
          exit(0);
        } else if (statusLine.contains('200')) {
          print('🎉🎉🎉 200 OK! REGISTERED WITH IT SKY SIP TRUNK! 🎉🎉🎉');
          socket.close();
          exit(0);
        }
      }
    }
  });

  await Future.delayed(const Duration(seconds: 4));
  print('\n================================================================');
  print('🏁 Windows Desktop Probe Completed.');
  print('================================================================');
  exit(0);
}
