import 'package:flutter/material.dart';
import '../../data/models/customer_model.dart';
import '../../data/repositories/customer_repository.dart';

enum LoadStatus { initial, loading, loaded, error }

class CustomerProvider extends ChangeNotifier {
  final CustomerRepository _repository = CustomerRepository();

  List<CustomerModel> _customers = [];
  LoadStatus _status = LoadStatus.initial;
  String? _errorMessage;

  List<CustomerModel> get customers => _customers;
  LoadStatus get status => _status;
  String? get errorMessage => _errorMessage;

  num get totalDebtAll => _customers.fold<num>(0, (sum, c) => sum + c.totalDebt);

  Future<void> loadCustomers() async {
    _status = LoadStatus.loading;
    notifyListeners();
    try {
      _customers = await _repository.getAllCustomers();
      _status = LoadStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = LoadStatus.error;
    }
    notifyListeners();
  }

  List<CustomerModel> search(String query) {
    if (query.trim().isEmpty) return _customers;
    final q = query.toLowerCase();
    return _customers.where((c) =>
    c.name.toLowerCase().contains(q) ||
        (c.telegramUsername?.toLowerCase().contains(q) ?? false) ||
        (c.phoneNumber?.contains(q) ?? false)).toList();
  }

  Future<bool> updateCustomer(String id, {String? name,String? phoneNumber ,bool? isActive}) async {
    try {
      await _repository.updateCustomer(id, name: name, isActive: isActive,phoneNumber: phoneNumber);
      await loadCustomers();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}