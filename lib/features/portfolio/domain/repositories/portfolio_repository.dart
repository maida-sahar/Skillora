import 'dart:io';
import '../../data/models/portfolio_item_model.dart';

abstract class PortfolioRepository {
  Future<String> uploadPortfolioImage({
    required String userId,
    required File imageFile,
  });

  Future<void> addPortfolioItem(PortfolioItemModel item);

  Future<List<PortfolioItemModel>> getUserPortfolioItems(String userId);
}
