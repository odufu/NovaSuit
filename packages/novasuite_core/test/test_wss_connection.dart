import 'dart:io';

void main() async {
  print('================================================================');
  print('🚀 Testing IT Sky WebSockets (WSS / WS) WebRTC Telephony Endpoints');
  print('================================================================');

  final endpoints = [
    'wss://07003100077.astpp.itskysolutions.com:8089/ws',
    'wss://07003100077.astpp.itskysolutions.com:8089/',
    'wss://astpp.itskysolutions.com:8089/ws',
    'wss://astpp.itskysolutions.com:443/ws',
    'wss://astpp.itskysolutions.com:8443/ws',
    'ws://95.217.244.97:8089/ws',
    'ws://95.217.244.97:5060',
    'ws://95.217.244.97:8089',
    'https://07003100077.astpp.itskysolutions.com:8089/ws',
    'https://astpp.itskysolutions.com:8089/ws',
  ];

  for (final url in endpoints) {
    print('\n📡 Testing Endpoint: $url ...');
    if (url.startsWith('ws://') || url.startsWith('wss://')) {
      try {
        final customClient = HttpClient()
          ..badCertificateCallback = (cert, host, port) => true;

        final socket = await WebSocket.connect(
          url,
          headers: {'Sec-WebSocket-Protocol': 'sip'},
          customClient: customClient,
        ).timeout(const Duration(seconds: 4));

        print('   🎉🎉🎉 SUCCESS! Connected to WebSocket Endpoint: $url! 🎉🎉🎉');
        socket.close();
      } catch (e) {
        print('   ❌ WebSocket Connection Error: $e');
      }
    } else {
      try {
        final client = HttpClient()
          ..badCertificateCallback = (cert, host, port) => true;
        final request = await client.getUrl(Uri.parse(url)).timeout(const Duration(seconds: 4));
        final response = await request.close().timeout(const Duration(seconds: 4));
        print('   👉 HTTPS Response: ${response.statusCode} ${response.reasonPhrase}');
      } catch (e) {
        print('   ❌ HTTPS Connection Error: $e');
      }
    }
  }

  print('\n================================================================');
  print('🏁 IT Sky WebSockets Connectivity Test Completed.');
  print('================================================================');
  exit(0);
}
