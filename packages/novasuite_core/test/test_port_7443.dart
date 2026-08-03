import 'dart:io';

void main() async {
  print('================================================================');
  print('🎯 Testing IT Sky Active WebRTC Port 7443 (wss://astpp.itskysolutions.com:7443/ws)');
  print('================================================================');

  final urls = [
    'wss://astpp.itskysolutions.com:7443/ws',
    'wss://astpp.itskysolutions.com:7443/',
    'wss://07003100077.astpp.itskysolutions.com:7443/ws',
    'wss://95.217.244.97:7443/ws',
  ];

  for (final url in urls) {
    print('\n📡 Handshaking with: $url ...');
    try {
      final customClient = HttpClient()
        ..badCertificateCallback = (cert, host, port) => true;

      final socket = await WebSocket.connect(
        url,
        protocols: ['sip'],
        customClient: customClient,
      ).timeout(const Duration(seconds: 4));

      print('🎉🎉🎉 WEBRTC WSS SUCCESS! 101 WebSocket Handshake Established on $url! 🎉🎉🎉');
      socket.close();
    } catch (e) {
      print('   ❌ Connection detail: $e');
    }
  }

  print('\n================================================================');
  print('🏁 Port 7443 Test Completed.');
  print('================================================================');
  exit(0);
}
