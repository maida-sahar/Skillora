import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/error/exceptions.dart';

abstract class FirestoreService {
  Future<Map<String, dynamic>?> getDocument(String collection, String id);
  Future<void> setDocument(String collection, String id, Map<String, dynamic> data, {bool merge = true});
  Future<void> updateDocument(String collection, String id, Map<String, dynamic> data);
  Future<void> deleteDocument(String collection, String id);
  Future<List<Map<String, dynamic>>> getCollection(String collection);
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchDocument(String collection, String id);
  Stream<QuerySnapshot<Map<String, dynamic>>> watchCollection(String collection);
}

class FirestoreServiceImpl implements FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreServiceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Map<String, dynamic>?> getDocument(String collection, String id) async {
    try {
      final doc = await _firestore.collection(collection).doc(id).get();
      return doc.data();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to fetch document.');
    } catch (e) {
      throw ServerException('Firestore read error: ${e.toString()}');
    }
  }

  @override
  Future<void> setDocument(String collection, String id, Map<String, dynamic> data, {bool merge = true}) async {
    try {
      await _firestore.collection(collection).doc(id).set(data, SetOptions(merge: merge));
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to write document.');
    } catch (e) {
      throw ServerException('Firestore write error: ${e.toString()}');
    }
  }

  @override
  Future<void> updateDocument(String collection, String id, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(id).update(data);
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update document.');
    } catch (e) {
      throw ServerException('Firestore update error: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteDocument(String collection, String id) async {
    try {
      await _firestore.collection(collection).doc(id).delete();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to delete document.');
    } catch (e) {
      throw ServerException('Firestore delete error: ${e.toString()}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCollection(String collection) async {
    try {
      final snapshot = await _firestore.collection(collection).get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to fetch collection.');
    } catch (e) {
      throw ServerException('Firestore query error: ${e.toString()}');
    }
  }

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchDocument(String collection, String id) {
    return _firestore.collection(collection).doc(id).snapshots();
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> watchCollection(String collection) {
    return _firestore.collection(collection).snapshots();
  }
}
