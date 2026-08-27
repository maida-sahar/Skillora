abstract class FirebaseStorageService {
  Future<String> uploadFile(String path, List<int> bytes);
  Future<void> deleteFile(String path);
}

class FirebaseStorageServiceImpl implements FirebaseStorageService {
  @override
  Future<String> uploadFile(String path, List<int> bytes) async => '';

  @override
  Future<void> deleteFile(String path) async {}
}
