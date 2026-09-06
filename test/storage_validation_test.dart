import 'package:flutter_test/flutter_test.dart';
import 'package:skillora/supabase/supabase_storage_service.dart';


void main() {
  group('SupabaseStorageService Path Extraction Tests', () {
    late SupabaseStorageService storageService;

    setUp(() {
      storageService = SupabaseStorageServiceImpl();
    });

    test('Extract path from avatars public URL', () {
      const url = 'https://xyz.supabase.co/storage/v1/object/public/avatars/user123/avatar_1690000000.jpg';
      final path = storageService.extractPathFromUrl('avatars', url);
      expect(path, equals('user123/avatar_1690000000.jpg'));
    });

    test('Extract path from portfolio-assets public URL', () {
      const url = 'https://xyz.supabase.co/storage/v1/object/public/portfolio-assets/user123/proj1/portfolio_1690000000.png';
      final path = storageService.extractPathFromUrl('portfolio-assets', url);
      expect(path, equals('user123/proj1/portfolio_1690000000.png'));
    });

    test('Extract path returns null for empty or invalid URL', () {
      expect(storageService.extractPathFromUrl('avatars', ''), isNull);
      expect(storageService.extractPathFromUrl('avatars', 'https://example.com/image.jpg'), isNull);
    });
  });
}
