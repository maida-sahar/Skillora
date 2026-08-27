import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../firebase/firestore_service.dart';
import '../../../../supabase/supabase_storage_service.dart';
import '../../domain/repositories/portfolio_repository.dart';
import '../models/portfolio_item_model.dart';

class PortfolioRepositoryImpl implements PortfolioRepository {
  final SupabaseStorageService _supabaseStorageService;
  final FirestoreService _firestoreService;

  PortfolioRepositoryImpl({
    SupabaseStorageService? supabaseStorageService,
    FirestoreService? firestoreService,
  })  : _supabaseStorageService = supabaseStorageService ?? SupabaseStorageServiceImpl(),
        _firestoreService = firestoreService ?? FirestoreServiceImpl();

  @override
  Future<String> uploadPortfolioImage({
    required String userId,
    required File imageFile,
  }) async {
    final String path = '$userId/portfolio_${DateTime.now().millisecondsSinceEpoch}.jpg';

    // Upload to Supabase 'portfolio-assets' public bucket
    final String publicUrl = await _supabaseStorageService.uploadImage(
      'portfolio-assets',
      path,
      imageFile,
    );

    return publicUrl;
  }

  @override
  Future<void> addPortfolioItem(PortfolioItemModel item) async {
    await _firestoreService.setDocument(
      'portfolios',
      item.id,
      item.toFirestore(),
    );
  }

  @override
  Future<List<PortfolioItemModel>> getUserPortfolioItems(String userId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('portfolios')
        .where('userId', isEqualTo: userId)
        .get();

    return querySnapshot.docs.map((doc) => PortfolioItemModel.fromFirestore(doc)).toList();
  }
}
