import 'package:flutter/material.dart';
import '../../../../core/services/telegram_service.dart';
import '../../../customers/data/models/customer_model.dart';
import '../../data/models/sale_item_model.dart';
import '../../data/repositories/sale_repository.dart';

class SaleProvider extends ChangeNotifier {
  final SaleRepository _repository = SaleRepository();

  CustomerModel? selectedCustomer;
  final List<SaleItemDraft> items = [];

  bool isSaving = false;
  String? errorMessage;

  num get grandTotal => items.fold<num>(0, (sum, item) => sum + item.total);

  void selectCustomer(CustomerModel customer) {
    selectedCustomer = customer;
    notifyListeners();
  }

  void addItem(SaleItemDraft item) {
    items.add(item);
    notifyListeners();
  }

  void removeItem(int index) {
    items.removeAt(index);
    notifyListeners();
  }

  void reset() {
    selectedCustomer = null;
    items.clear();
    errorMessage = null;
    notifyListeners();
  }

  Future<bool> saveSale({
    required num cashPaid,
    required num debtAmount,
    DateTime? debtDueDate,
  }) async {
    if (selectedCustomer == null || items.isEmpty) return false;
    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _repository.createSale(
        customerId: selectedCustomer!.id,
        grandTotal: grandTotal,
        cashPaid: cashPaid,
        debtAmount: debtAmount,
        debtDueDate: debtDueDate,
        items: items,
      );

      final chatId = selectedCustomer!.telegramChatId;
      if (chatId != null) {
        // Mijozning shu savdogacha bo'lgan qarziga yangi nasiyani qo'shib,
        // umumiy qarzni hisoblaymiz (mijozning eski totalDebt'i tanlanganda yuklangan)
        final totalDebtAfter = selectedCustomer!.totalDebt + debtAmount;

        final message = TelegramService.buildSaleMessage(
          date: DateTime.now(),
          debtDueDate: debtDueDate,
          items: items
              .map((e) => {
            'name': e.productName,
            'price': e.price,
            'qty': e.quantity,
            'total': e.total,
          })
              .toList(),
          grandTotal: grandTotal,
          cash: cashPaid,
          debt: debtAmount,
          totalDebtAfter: totalDebtAfter,
        );
        await TelegramService.sendMessage(chatId: chatId.toString(), text: message);
      }

      isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isSaving = false;
      notifyListeners();
      return false;
    }
  }
}