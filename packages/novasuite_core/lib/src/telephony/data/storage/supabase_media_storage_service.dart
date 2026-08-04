import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/i_media_storage_service.dart';

class SupabaseMediaStorageService implements IMediaStorageService {
  static final SupabaseMediaStorageService _instance = SupabaseMediaStorageService._internal();
  factory SupabaseMediaStorageService() => _instance;
  SupabaseMediaStorageService._internal();

  SupabaseClient get _client => Supabase.instance.client;
  static const String _bucketName = 'call_recordings';

  @override
  Future<String?> uploadCallRecording({
    required File file,
    required String callId,
    required String customerPhone,
  }) async {
    try {
      if (!await file.exists()) {
        print('⚠️ [Storage] Local call recording file does not exist: ${file.path}');
        return null;
      }

      final fileName = file.path.split(Platform.pathSeparator).last;
      final storagePath = 'recordings/$fileName';

      print('☁️ [Storage] Uploading call recording to Supabase Storage bucket "$_bucketName"...');

      await _client.storage.from(_bucketName).upload(
        storagePath,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      final publicUrl = _client.storage.from(_bucketName).getPublicUrl(storagePath);
      print('✅ [Storage] Upload completed! Public Cloud URL: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('⚠️ [Storage] Error uploading call recording to Supabase Storage: $e');
      return null;
    }
  }

  @override
  Future<bool> deleteCallRecording(String cloudUrlOrPath) async {
    try {
      String storagePath = cloudUrlOrPath;
      if (cloudUrlOrPath.contains('$_bucketName/')) {
        storagePath = cloudUrlOrPath.split('$_bucketName/').last;
      }
      print('🗑️ [Storage] Programmatically purging call recording from cloud storage: $storagePath');
      await _client.storage.from(_bucketName).remove([storagePath]);
      print('✅ [Storage] Call recording purged successfully.');
      return true;
    } catch (e) {
      print('⚠️ [Storage] Error purging call recording from cloud storage: $e');
      return false;
    }
  }
}
