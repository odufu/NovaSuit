/// Centralized IT Sky Solutions SIP Interconnect Secret Configuration & Telephony Routing Engine
class ItSkySipConfig {
  /// IT Sky Solutions Target Provider SIP Host & Parameters (Verified via MicroSIP)
  static const String providerSipHost = '95.217.244.97';
  static const String providerSipDomain = '07003100077.astpp.itskysolutions.com';
  static const int providerSipPort = 5060;
  static const String providerSipEndpoint = '95.217.244.97';

  /// Verified MicroSIP Credentials & Parameters
  static const String assignedUsername = '07003100077';
  static const String assignedPassword = 'C)Jz2(yC';
  static const String assignedDidNumber = '07003100077';
  static const String defaultDisplayName = 'NovaSuite Live Agent';

  /// 1. CURRENT CONFIGURATION (Native MicroSIP / Desktop UDP 5060)
  static Map<String, dynamic> get currentUdpConfig => {
        'transport': 'UDP',
        'sipHost': providerSipHost,
        'sipDomain': providerSipDomain,
        'sipPort': providerSipPort,
        'username': assignedUsername,
        'password': assignedPassword,
        'did': assignedDidNumber,
        'userAgent': 'MicroSIP/3.21.3',
      };

  /// 2. TARGET WSS CONFIGURATION (Web Browser WebRTC)
  static Map<String, dynamic> get targetWssConfig => {
        'transport': 'WSS',
        'webSocketUri': wssPort7443Url,
        'sipDomain': providerSipDomain,
        'sipPort': wssWebRtcPort,
        'username': assignedUsername,
        'password': assignedPassword,
        'did': assignedDidNumber,
        'userAgent': 'NovaCare-WebRTC/1.0 (SIP.js)',
        'stunServer': 'stun:stun.l.google.com:19302',
      };

  /// Convenient Alias Getters
  static String get username => assignedUsername;
  static String get password => assignedPassword;
  static String get domain => providerSipDomain;

  /// Transport & Registration Settings
  static const String defaultTransport = 'UDP';
  static const int registerRefreshSeconds = 300;
  static const int keepAliveSeconds = 15;
  static const bool allowIpRewrite = true;

  /// Supabase Cloud Whitelisted Public IP
  static const String whitelistedServerIp = '104.18.38.10';

  /// Signaling Ports & WebRTC Proxy Endpoints
  static const int udpSignalingPort = 5060;
  static const int wssWebRtcPort = 7443;
  static const String wssPort7443Url = 'wss://astpp.itskysolutions.com:7443';
  static const String wssWebRtcUrl = 'wss://07003100077.astpp.itskysolutions.com:8089/ws';
  static const String wsWebRtcUrl = 'ws://07003100077.astpp.itskysolutions.com:8089/ws';
  static const String wsDirectIpUrl = 'ws://95.217.244.97:8089/ws';
  static const String wsPort5060Url = 'ws://95.217.244.97:5060';

  /// All Fallback Transport Endpoints (WebSockets Only)
  static const List<String> fallbackWebSocketUrls = [
    wssPort7443Url,
    wssWebRtcUrl,
    wsWebRtcUrl,
    wsDirectIpUrl,
  ];

  /// Authentication Strategy
  static const String authStrategy = 'DIGEST_AUTHENTICATION';
  static const bool requiresDigestAuth = true;

  /// Supported Voice Codecs
  static const List<String> supportedCodecs = ['G711alaw', 'G711ulaw', 'G729'];

  /// Key Technical Support Contacts at IT Sky Solutions
  static const Map<String, String> technicalContacts = {
    'Muhammad': '09160331333',
    'Maryann': '08133355766',
    'Abubakar': '09065655211',
  };

  /// Formats outbound numbers for IT Sky Solutions SIP Trunk routing (converts +234/234 to local 080... format)
  static String formatOutboundDialString(String rawPhone) {
    final cleaned = rawPhone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleaned.startsWith('+234')) {
      return '0${cleaned.substring(4)}';
    }
    if (cleaned.startsWith('234')) {
      return '0${cleaned.substring(3)}';
    }
    return cleaned;
  }
}
