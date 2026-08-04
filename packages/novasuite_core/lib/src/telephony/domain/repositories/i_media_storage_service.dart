import 'dart:io';

abstract class IMediaStorageService {
  /// Uploads local call recording file to cloud storage (Supabase Storage or Cloudinary)
  Future<String?> uploadCallRecording({
    required File file,
    required String callId,
    required String customerPhone,
  });

  /// Deletes call recording from cloud storage programmatically for storage management & purging
  Future<bool> deleteCallRecording(String cloudUrlOrPath);
}
