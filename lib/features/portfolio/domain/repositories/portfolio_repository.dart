import 'dart:io';
import 'dart:typed_data';
import '../../data/models/portfolio_item_model.dart';

abstract class PortfolioRepository {
  Future<String> uploadPortfolioImage({
    required String userId,
    File? imageFile,
    Uint8List? imageBytes,
    String? fileName,
    String? projectId,
  });

  Future<void> addPortfolioItem(PortfolioItemModel item);

  Future<List<PortfolioItemModel>> getUserPortfolioItems(String userId);
}

