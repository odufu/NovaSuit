import 'dart:io';

void main() async {
  print('================================================================');
  print('🔎 Probing IT Sky WebSockets Ports & Paths (443, 8443, 5066, 7443, 8088)');
  print('================================================================');

  const host = 'astpp.itskysolutions.com';
  final ports = [443, 8443, 5066, 7443, 8088, 5060];
  final paths = ['/ws', '/websocket', '/sip', '/wss', '/'];

  for (final port in ports) {
    for (final path in paths) {
      final url = 'wss://$host:$port$path';
      try {
        final customClient = HttpClient()
          ..badCertificateCallback = (cert, host, port) => true;

        final socket = await WebSocket.connect(
          url,
          headers: {'Sec-WebSocket-Protocol': 'sip'},
          customClient: customClient,
        ).timeout(const Duration(seconds: 2));

        print('🎉🎉🎉 FOUND LIVE WSS ENDPOINT! Connected to: $url 🎉🎉🎉');
        socket.close();
      } catch (e) {
        final errStr = e.toString();
        if (!errStr.contains('refused') && !errStr.contains('timed out')) {
          print('👉 Port $port $path -> $errStr');
        }
      }
    }
  }

  print('\n================================================================');
  print('🏁 Path Probe Completed.');
  print('================================================================');
  exit(0);
}
