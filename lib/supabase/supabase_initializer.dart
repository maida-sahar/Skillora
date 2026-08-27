import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseInitializer {
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      debugPrint('Warning: .env file loading failed or missing. Using environment fallbacks.');
    }

    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    if (supabaseUrl.isEmpty ||
        supabaseAnonKey.isEmpty ||
        supabaseUrl.contains('your-supabase-project-ref')) {
      debugPrint('Warning: Supabase credentials not fully configured in .env. Skipping Supabase.initialize().');
      return;
    }

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabaseAnonKey,
      );
      debugPrint('Supabase Infrastructure Initialized successfully.');
    } catch (e) {
      debugPrint('Supabase Initialization Error: $e');
    }
  }
}
