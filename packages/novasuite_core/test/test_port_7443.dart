import 'dart:io';

void main() async {
  print('================================================================');
  print('🎯 Deep Testing IT Sky WebSockets Connections across Ports & Protocols');
  print('================================================================');

  final urls = [
    'wss://astpp.itskysolutions.com:7443',
    'wss://astpp.itskysolutions.com:7443/',
    'wss://astpp.itskysolutions.com:7443/ws',
    'wss://astpp.itskysolutions.com:7443/sip',
    'wss://astpp.itskysolutions.com:5066',
    'wss://astpp.itskysolutions.com:5066/ws',
    'wss://astpp.itskysolutions.com:8089',
    'wss://astpp.itskysolutions.com:8089/ws',
    'wss://astpp.itskysolutions.com:443/ws',
    'wss://07003100077.astpp.itskysolutions.com:7443',
    'wss://95.217.244.97:7443',
  ];

  for (final url in urls) {
    print('\n-----------------------------------------------------');
    print('📡 Testing URL: $url');

    // Test 1: With 'sip' subprotocol header
    try {
      final customClient = HttpClient()
        ..badCertificateCallback = (cert, host, port) => true;

      final socket = await WebSocket.connect(
        url,
        protocols: ['sip'],
        customClient: customClient,
      ).timeout(const Duration(seconds: 3));

      print('   🎉 SUCCESS (with sip protocol)! Connected to $url');
      await socket.close();
    } catch (e) {
      print('   ❌ With sip subprotocol error: $e');
    }

    // Test 2: Without subprotocol header
    try {
      final customClient = HttpClient()
        ..badCertificateCallback = (cert, host, port) => true;

      final socket = await WebSocket.connect(
        url,
        customClient: customClient,
      ).timeout(const Duration(seconds: 3));

      print('   🎉 SUCCESS (no subprotocol)! Connected to $url');
      await socket.close();
    } catch (e) {
      print('   ❌ No subprotocol error: $e');
    }
  }

  print('\n================================================================');
  print('🏁 Deep Probe Completed.');
  print('================================================================');
  exit(0);
}
