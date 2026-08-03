import 'dart:io';

void main() async {
  print('================================================================');
  print('🔎 Probing IT Sky HTTPS Ports (443, 7443, 8443)');
  print('================================================================');

  final urls = [
    'https://astpp.itskysolutions.com',
    'https://astpp.itskysolutions.com:7443',
    'https://astpp.itskysolutions.com:8443',
    'https://07003100077.astpp.itskysolutions.com',
    'https://95.217.244.97:5060',
  ];

  for (final url in urls) {
    print('\n📡 GET $url ...');
    try {
      final client = HttpClient()
        ..badCertificateCallback = (cert, host, port) {
          print('   🔒 SSL Certificate Subject: ${cert.subject}');
          print('   🔒 SSL Certificate Issuer: ${cert.issuer}');
          return true;
        };

      final request = await client.getUrl(Uri.parse(url)).timeout(const Duration(seconds: 4));
      final response = await request.close().timeout(const Duration(seconds: 4));
      print('   👉 Status: ${response.statusCode} ${response.reasonPhrase}');
      print('   👉 Server Header: ${response.headers.value("server")}');
    } catch (e) {
      print('   ❌ Connection Error: $e');
    }
  }

  print('\n================================================================');
  print('🏁 HTTP Probe Completed.');
  print('================================================================');
  exit(0);
}
