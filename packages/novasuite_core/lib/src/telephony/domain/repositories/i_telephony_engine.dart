import 'dart:async';
import '../../../models/order.dart';

enum TelephonyEngineStatus {
  unregistered,
  registering,
  registered,
  registrationFailed,
}

enum TelephonyCallState {
  idle,
  connecting,
  ringing,
  incomingCall,
  active,
  ended,
  disconnected,
}

abstract class ITelephonyEngine {
  Stream<TelephonyEngineStatus> get statusStream;
  Stream<TelephonyCallState> get callStateStream;
  Stream<int> get durationStream;
  Stream<String> get providerReasonStream;

  TelephonyEngineStatus get status;
  TelephonyCallState get callState;
  String? get incomingCallerNumber;

  Future<bool> register();
  Future<void> initiateOutboundCall(OrderModel order);
  Future<void> answerIncomingCall();
  void hangup();
}
