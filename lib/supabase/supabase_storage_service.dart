import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/error/exceptions.dart';

abstract class SupabaseStorageService {
  Future<String> uploadImageBytes(
    String bucket,
    String path,
    Uint8List bytes, {
    String? contentType,
  });

  Future<String> uploadFileBytes(
    String bucket,
    String path,
    Uint8List bytes, {
    String? contentType,
  });

  Future<String> uploadImage(String bucket, String path, File file);
  Future<String> uploadFile(String bucket, String path, File file);
  Future<String> getSignedUrl(String bucket, String path, {int expiresInSeconds = 3600});
  Future<void> deleteImage(String bucket, String path);
  String? extractPathFromUrl(String bucket, String publicUrl);
}

class SupabaseStorageServiceImpl implements SupabaseStorageService {
  final SupabaseClient? _customClient;

  SupabaseStorageServiceImpl({SupabaseClient? client})
      : _customClient = client;

  SupabaseClient get _client => _customClient ?? Supabase.instance.client;


  @override
  Future<String> uploadImageBytes(
    String bucket,
    String path,
    Uint8List bytes, {
    String? contentType,
  }) async {
    try {
      await _client.storage.from(bucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              cacheControl: '3600',
              upsert: true,
              contentType: contentType,
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
  Future<String> uploadFileBytes(
    String bucket,
    String path,
    Uint8List bytes, {
    String? contentType,
  }) async {
    try {
      await _client.storage.from(bucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              cacheControl: '3600',
              upsert: true,
              contentType: contentType,
            ),
          );

      // Return storage path for private bucket, or public URL for public bucket
      if (bucket == 'user-documents') {
        return path;
      }
      return _client.storage.from(bucket).getPublicUrl(path);
    } on StorageException catch (e) {
      throw ServerException(e.message, statusCode: int.tryParse(e.statusCode ?? '500'));
    } catch (e) {
      throw ServerException('Failed to upload file to Supabase Storage: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadImage(String bucket, String path, File file) async {
    final bytes = await file.readAsBytes();
    return uploadImageBytes(bucket, path, bytes);
  }

  @override
  Future<String> uploadFile(String bucket, String path, File file) async {
    final bytes = await file.readAsBytes();
    return uploadFileBytes(bucket, path, bytes);
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

  @override
  String? extractPathFromUrl(String bucket, String publicUrl) {
    if (publicUrl.isEmpty) return null;
    final marker = '/storage/v1/object/public/$bucket/';
    final index = publicUrl.indexOf(marker);
    if (index != -1) {
      return publicUrl.substring(index + marker.length);
    }
    return null;
  }
}

