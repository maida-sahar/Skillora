abstract class FCMService {
  Future<void> initializeMessaging();
  Future<String?> getToken();
}

class FCMServiceImpl implements FCMService {
  @override
  Future<void> initializeMessaging() async {}

  @override
  Future<String?> getToken() async => null;
}
