import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';

class FirebaseInitializer {
  static Future<void> init() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('Firebase Infrastructure Initialized successfully.');
    } catch (e) {
      debugPrint('Firebase Initialization Error: $e');
    }
  }
}
