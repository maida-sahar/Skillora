import 'package:flutter/foundation.dart';

/// Global Observer class for tracking app-wide state changes cleanly
class AppObserver {
  static void logStateChange(String providerName, dynamic previous, dynamic next) {
    if (kDebugMode) {
      debugPrint('[StateChange] $providerName: $previous -> $next');
    }
  }

  static void logError(String providerName, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('[StateError] $providerName: $error');
      debugPrint(stackTrace.toString());
    }
  }
}
