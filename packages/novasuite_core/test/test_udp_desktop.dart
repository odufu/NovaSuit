import 'dart:io';
import 'dart:convert';

void main() async {
  print('================================================================');
  print('🎯 Testing Windows Desktop Native UDP 5060 SIP Trunk Connection');
  print('================================================================');

  const sipServerIp = '95.217.244.97';
  const sipPort = 5060;
  const username = '07003100077';
  const domain = '07003100077.astpp.itskysolutions.com';

  print('📡 Binding Local UDP Socket on Windows Desktop...');
  try {
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    print('   ✅ Bound local socket on port: ${socket.port}');

    final sipOptionsPacket = 
      'OPTIONS sip:$domain SIP/2.0\r\n'
      'Via: SIP/2.0/UDP 127.0.0.1:${socket.port};rport;branch=z9hG4bK-novasuite-${DateTime.now().millisecondsSinceEpoch}\r\n'
      'From: <sip:$username@$domain>;tag=novacare-win-${DateTime.now().millisecondsSinceEpoch}\r\n'
      'To: <sip:$domain>\r\n'
      'Call-ID: win-desktop-${DateTime.now().millisecondsSinceEpoch}@127.0.0.1\r\n'
      'CSeq: 1 OPTIONS\r\n'
      'Contact: <sip:$username@127.0.0.1:${socket.port}>\r\n'
      'Max-Forwards: 70\r\n'
      'User-Agent: NovaCare-WindowsDesktop/1.0 (MicroSIP-Parity)\r\n'
      'Content-Length: 0\r\n\r\n';

    print('\n📡 Sending SIP OPTIONS Handshake to $sipServerIp:$sipPort (Parity with MicroSIP)...');
    final bytesSent = socket.send(utf8.encode(sipOptionsPacket), InternetAddress(sipServerIp), sipPort);
    print('   👉 Bytes Transmitted: $bytesSent bytes');

    bool receivedResponse = false;
    socket.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        final datagram = socket.receive();
        if (datagram != null) {
          receivedResponse = true;
          final responseStr = utf8.decode(datagram.data);
          print('\n🎉🎉🎉 WINDOWS DESKTOP NATIVE UDP SIP SUCCESS! 🎉🎉🎉');
          print('   👉 Sender: ${datagram.address.address}:${datagram.port}');
          print('   👉 Response Packet Snippet:\n');
          print(responseStr.split('\r\n').take(4).join('\n'));
          socket.close();
          exit(0);
        }
      }
    });

    await Future.delayed(const Duration(seconds: 4));
    if (!receivedResponse) {
      print('   ⏱️ Timeout waiting for UDP response. Server firewall or NAT rport active.');
      socket.close();
    }
  } catch (e) {
    print('   ❌ Windows UDP Socket Error: $e');
  }

  print('\n================================================================');
  print('🏁 Windows Desktop UDP Probe Completed.');
  print('================================================================');
  exit(0);
}
