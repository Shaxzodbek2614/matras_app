import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

enum LoadStatus { initial, loading, loaded, error }

/// Mahsulotlar ro'yxati va CRUD amallarini boshqaruvchi provider
class ProductProvider extends ChangeNotifier {
  final ProductRepository _repository = ProductRepository();

  List<ProductModel> _products = [];
  LoadStatus _status = LoadStatus.initial;
  String? _errorMessage;

  List<ProductModel> get products => _products;
  LoadStatus get status => _status;
  String? get errorMessage => _errorMessage;

  Future<void> loadProducts() async {
    _status = LoadStatus.loading;
    notifyListeners();
    try {
      _products = await _repository.getAllProducts();
      _status = LoadStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  Future<List<ProductModel>> loadActiveProducts() {
    return _repository.getActiveProducts();
  }

  Future<bool> addProduct({required String name, required String size, required num price}) async {
    try {
      await _repository.addProduct(ProductModel(
        id: '',
        name: name,
        size: size,
        price: price,
        isActive: true,
        createdAt: DateTime.now(),
      ));
      await loadProducts();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(String id, {required String name, required String size, required num price}) async {
    try {
      await _repository.updateProduct(id, {'name': name, 'size': size, 'price': price});
      await loadProducts();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleActive(ProductModel product) async {
    try {
      await _repository.setActiveStatus(product.id, !product.isActive);
      await loadProducts();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
