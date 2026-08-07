/// Cross-platform stub for NovaWindowsFocusService (Web / Mobile)
class NovaWindowsFocusService {
  static final NovaWindowsFocusService _instance = NovaWindowsFocusService._internal();
  factory NovaWindowsFocusService() => _instance;
  NovaWindowsFocusService._internal();

  /// No-op stub on non-Windows platforms
  void bringAppToForegroundAndFlash() {}
}
