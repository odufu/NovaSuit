import 'dart:io';
import 'package:novasuite_core/novasuite_core.dart';

void main() async {
  print('================================================================');
  print('💻 Testing Windows Desktop Native UDP SIP Registration Engine');
  print('================================================================');

  print('📡 Initializing NovaUdpSipEngine for Windows Desktop...');
  final engine = NovaUdpSipEngine();

  print('🔒 Username: ${ItSkySipConfig.username}');
  print('🌐 Server IP: ${ItSkySipConfig.serverIp}:${ItSkySipConfig.udpPort}');

  try {
    final success = await engine.initialize();
    print('\n🎉 NovaUdpSipEngine Initialized: $success');
    print('   👉 Current State: ${engine.state}');

    if (engine.state == UdpCallState.registered) {
      print('🎉🎉🎉 WINDOWS DESKTOP NATIVE UDP SIP REGISTER SUCCESS! 🎉🎉🎉');
    } else {
      print('ℹ️ Engine State: ${engine.state} | Last Error: ${engine.lastError}');
    }
  } catch (e) {
    print('❌ Error during Windows Desktop UDP test: $e');
  }

  print('\n================================================================');
  print('🏁 Windows Desktop Engine Test Completed.');
  print('================================================================');
  exit(0);
}
