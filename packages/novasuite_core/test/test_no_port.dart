import 'dart:io';

void main() async {
  print('================================================================');
  print('🎯 Testing IT Sky WSS Standard Endpoints WITHOUT Port Specification');
  print('================================================================');

  final urls = [
    'wss://astpp.itskysolutions.com',
    'wss://astpp.itskysolutions.com/',
    'wss://astpp.itskysolutions.com/ws',
    'wss://astpp.itskysolutions.com/sip',
    'wss://07003100077.astpp.itskysolutions.com',
    'wss://07003100077.astpp.itskysolutions.com/ws',
  ];

  for (final url in urls) {
    print('\n📡 Testing URL (Standard Port 443 WSS): $url');

    // Test 1: With 'sip' subprotocol
    try {
      final customClient = HttpClient()
        ..badCertificateCallback = (cert, host, port) => true;

      final socket = await WebSocket.connect(
        url,
        protocols: ['sip'],
        customClient: customClient,
      ).timeout(const Duration(seconds: 4));

      print('🎉🎉🎉 WEBRTC WSS SUCCESS (with sip subprotocol)! Connected to $url! 🎉🎉🎉');
      await socket.close();
    } catch (e) {
      print('   ❌ With sip subprotocol error: $e');
    }

    // Test 2: Without subprotocol
    try {
      final customClient = HttpClient()
        ..badCertificateCallback = (cert, host, port) => true;

      final socket = await WebSocket.connect(
        url,
        customClient: customClient,
      ).timeout(const Duration(seconds: 4));

      print('🎉🎉🎉 WEBRTC WSS SUCCESS (no subprotocol)! Connected to $url! 🎉🎉🎉');
      await socket.close();
    } catch (e) {
      print('   ❌ No subprotocol error: $e');
    }
  }

  print('\n================================================================');
  print('🏁 Standard Port 443 Probe Completed.');
  print('================================================================');
  exit(0);
}
