import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized Supabase Configuration & Initialization for NovaSuite Apps
class SupabaseConfig {
  static const String projectId = 'oygtaeriljuelhshfvkv';
  static const String supabaseUrl = 'https://oygtaeriljuelhshfvkv.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im95Z3RhZXJpbGp1ZWxoc2hmdmt2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM4Njg3MDAsImV4cCI6MjA5OTQ0NDcwMH0.o32kkHf1QSUs2xy4_5RrTFGw7_T-3iI8YGDml72oGxc';

  /// Initializes Supabase Flutter SDK
  static Future<Supabase> init() async {
    return await Supabase.initialize(
      url: supabaseUrl,
      // ignore: deprecated_member_use
      anonKey: anonKey,
    );
  }

  /// Direct handle to Supabase Client instance
  static SupabaseClient get client => Supabase.instance.client;
}
