import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';

/// Native Windows API service to bring app window to front focus and flash taskbar icon
class NovaWindowsFocusService {
  static final NovaWindowsFocusService _instance = NovaWindowsFocusService._internal();
  factory NovaWindowsFocusService() => _instance;
  NovaWindowsFocusService._internal();

  /// Forces the Windows Desktop Application to restore from minimized state, bring to foreground focus, and flash taskbar icon
  void bringAppToForegroundAndFlash() {
    if (kIsWeb || !Platform.isWindows) return;

    try {
      final user32 = DynamicLibrary.open('user32.dll');

      final findWindowW = user32.lookupFunction<
          IntPtr Function(Pointer<Utf16> lpClassName, Pointer<Utf16> lpWindowName),
          int Function(Pointer<Utf16> lpClassName, Pointer<Utf16> lpWindowName)>('FindWindowW');

      final showWindow = user32.lookupFunction<
          Int32 Function(IntPtr hWnd, Int32 nCmdShow),
          int Function(int hWnd, int nCmdShow)>('ShowWindow');

      final setForegroundWindow = user32.lookupFunction<
          Int32 Function(IntPtr hWnd),
          int Function(int hWnd)>('SetForegroundWindow');

      final flashWindow = user32.lookupFunction<
          Int32 Function(IntPtr hWnd, Int32 bInvert),
          int Function(int hWnd, int bInvert)>('FlashWindow');

      // Search by known window class names or titles
      int hwnd = 0;
      final classPtr = 'FLUTTER_RUNNER_WIN32_WINDOW'.toNativeUtf16();
      hwnd = findWindowW(classPtr, nullptr);
      malloc.free(classPtr);

      if (hwnd == 0) {
        final titles = ['novasuite_admin', 'NovaSuite Admin', 'NovaSuite'];
        for (final title in titles) {
          final titlePtr = title.toNativeUtf16();
          hwnd = findWindowW(nullptr, titlePtr);
          malloc.free(titlePtr);
          if (hwnd != 0) break;
        }
      }

      if (hwnd != 0) {
        // SW_RESTORE = 9, SW_SHOW = 5
        showWindow(hwnd, 9);
        setForegroundWindow(hwnd);
        flashWindow(hwnd, 1);
        print('⚡ [NATIVE WIN32] Restored window (hWnd: $hwnd) & forced foreground focus for Inbound Call!');
      } else {
        print('⚠️ [NATIVE WIN32] Window handle not found for focus bringing.');
      }
    } catch (e) {
      print('⚠️ [NATIVE WIN32] Error bringing app to foreground: $e');
    }
  }
}
