import 'dart:async';
import '../../../../firebase/firebase_auth_service.dart';
import '../../../../firebase/firestore_service.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;

  AuthRepositoryImpl({
    FirebaseAuthService? authService,
    FirestoreService? firestoreService,
  })  : _authService = authService ?? FirebaseAuthServiceImpl(),
        _firestoreService = firestoreService ?? FirestoreServiceImpl();

  @override
  Stream<UserModel?> get authStateChanges {
    return _authService.authStateChanges.asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return await _getUserFromFirestore(firebaseUser.uid);
    });
  }

  @override
  Future<UserModel?> getCurrentUserData() async {
    final uid = _authService.getCurrentUserId();
    if (uid == null) return null;
    return await _getUserFromFirestore(uid);
  }

  @override
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    final credential = await _authService.signInWithEmailAndPassword(email, password);
    final user = credential.user;
    if (user == null) throw const AuthException('User credentials invalid.');

    final userModel = await _getUserFromFirestore(user.uid);
    if (userModel == null) {
      // Fallback: Create user record if missing
      return await _createUserRecordInFirestore(
        uid: user.uid,
        name: user.displayName ?? email.split('@').first,
        email: email,
      );
    }
    return userModel;
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _authService.createUserWithEmailAndPassword(email, password);
    final user = credential.user;
    if (user == null) throw const AuthException('Failed to create user account.');

    return await _createUserRecordInFirestore(
      uid: user.uid,
      name: name,
      email: email,
    );
  }

  @override
  Future<UserModel?> signInWithGoogle() async {
    final credential = await _authService.signInWithGoogle();
    if (credential == null) return null; // User cancelled
    final user = credential.user;
    if (user == null) throw const AuthException('Google Sign-In user account invalid.');

    final existingUser = await _getUserFromFirestore(user.uid);
    if (existingUser != null) {
      return existingUser;
    }

    return await _createUserRecordInFirestore(
      uid: user.uid,
      name: user.displayName ?? 'Skillora User',
      email: user.email ?? '',
      avatarUrl: user.photoURL,
    );
  }

  @override
  Future<void> signOut() async {
    await _authService.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _authService.sendPasswordResetEmail(email);
  }

  Future<UserModel?> _getUserFromFirestore(String uid) async {
    try {
      final docData = await _firestoreService.getDocument('users', uid);
      if (docData == null) return null;
      return UserModel.fromMap(docData, uid);
    } catch (_) {
      return null;
    }
  }

  Future<UserModel> _createUserRecordInFirestore({
    required String uid,
    required String name,
    required String email,
    String? avatarUrl,
  }) async {
    final now = DateTime.now();
    final userModel = UserModel(
      id: uid,
      email: email,
      displayName: name,
      role: 'student', // FORCE DEFAULT ROLE 'student'
      avatarUrl: avatarUrl,
      createdAt: now,
      updatedAt: now,
    );

    await _firestoreService.setDocument('users', uid, userModel.toFirestore());
    return userModel;
  }
}
