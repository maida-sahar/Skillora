import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/error/exceptions.dart';

abstract class SupabaseStorageService {
  Future<String> uploadImage(String bucket, String path, File file);
  Future<String> uploadFile(String bucket, String path, File file);
  Future<String> getSignedUrl(String bucket, String path, {int expiresInSeconds = 3600});
  Future<void> deleteImage(String bucket, String path);
}

class SupabaseStorageServiceImpl implements SupabaseStorageService {
  final SupabaseClient _client;

  SupabaseStorageServiceImpl({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<String> uploadImage(String bucket, String path, File file) async {
    try {
      await _client.storage.from(bucket).upload(
            path,
            file,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      final String publicUrl = _client.storage.from(bucket).getPublicUrl(path);
      return publicUrl;
    } on StorageException catch (e) {
      throw ServerException(e.message, statusCode: int.tryParse(e.statusCode ?? '500'));
    } catch (e) {
      throw ServerException('Failed to upload image to Supabase Storage: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadFile(String bucket, String path, File file) async {
    try {
      await _client.storage.from(bucket).upload(
            path,
            file,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: true,
            ),
          );

      final String publicUrl = _client.storage.from(bucket).getPublicUrl(path);
      return publicUrl;
    } on StorageException catch (e) {
      throw ServerException(e.message, statusCode: int.tryParse(e.statusCode ?? '500'));
    } catch (e) {
      throw ServerException('Failed to upload file to Supabase Storage: ${e.toString()}');
    }
  }

  @override
  Future<String> getSignedUrl(String bucket, String path, {int expiresInSeconds = 3600}) async {
    try {
      final String signedUrl = await _client.storage.from(bucket).createSignedUrl(
            path,
            expiresInSeconds,
          );
      return signedUrl;
    } on StorageException catch (e) {
      throw ServerException(e.message, statusCode: int.tryParse(e.statusCode ?? '500'));
    } catch (e) {
      throw ServerException('Failed to generate signed URL: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteImage(String bucket, String path) async {
    try {
      await _client.storage.from(bucket).remove([path]);
    } on StorageException catch (e) {
      throw ServerException(e.message, statusCode: int.tryParse(e.statusCode ?? '500'));
    } catch (e) {
      throw ServerException('Failed to delete image from Supabase Storage: ${e.toString()}');
    }
  }
}
