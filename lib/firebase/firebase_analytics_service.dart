abstract class FirebaseAnalyticsService {
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters});
}

class FirebaseAnalyticsServiceImpl implements FirebaseAnalyticsService {
  @override
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {}
}
