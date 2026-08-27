import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/app.dart';
import 'app/app_env.dart';
import 'firebase/firebase_initializer.dart';
import 'supabase/supabase_initializer.dart';

void main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Lock preferred screen orientation
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Initialize Environment
    AppEnv.initialize(Environment.development);

    // Initialize Firebase Infrastructure cleanly
    await FirebaseInitializer.init();

    // Initialize Supabase Storage Infrastructure
    await SupabaseInitializer.init();

    runApp(const SkilloraApp());
  }, (error, stackTrace) {
    debugPrint('Uncaught Global Error: $error');
    debugPrint(stackTrace.toString());
  });
}
