import '../../../../core/services/supabase_service.dart';
import '../models/product_model.dart';

/// products jadvali bilan ishlash uchun repository (data qatlami)
class ProductRepository {
  final _client = SupabaseService.client;
  static const _table = 'products';

  Future<List<ProductModel>> getAllProducts() async {
    final data = await _client.from(_table).select().order('created_at', ascending: false);
    return (data as List).map((e) => ProductModel.fromJson(e)).toList();
  }

  /// Faqat sotishda ko'rsatiladigan faol mahsulotlar
  Future<List<ProductModel>> getActiveProducts() async {
    final data = await _client
        .from(_table)
        .select()
        .eq('is_active', true)
        .order('name', ascending: true);
    return (data as List).map((e) => ProductModel.fromJson(e)).toList();
  }

  Future<void> addProduct(ProductModel product) async {
    await _client.from(_table).insert(product.toInsertJson());
  }

  Future<void> updateProduct(String id, Map<String, dynamic> changes) async {
    await _client.from(_table).update(changes).eq('id', id);
  }

  Future<void> setActiveStatus(String id, bool isActive) async {
    await _client.from(_table).update({'is_active': isActive}).eq('id', id);
  }

  Future<void> deleteProduct(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}
