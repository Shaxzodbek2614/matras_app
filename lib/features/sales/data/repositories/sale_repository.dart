import '../../../../core/services/supabase_service.dart';
import '../models/sale_item_model.dart';

class SaleRepository {
  final _client = SupabaseService.client;

  Future<String> createSale({
    required String customerId,
    required num grandTotal,
    required num cashPaid,
    required num debtAmount,
    DateTime? debtDueDate,
    required List<SaleItemDraft> items,
  }) async {
    final saleData = await _client
        .from('sales')
        .insert({
      'customer_id': customerId,
      'grand_total': grandTotal,
      'cash_paid': cashPaid,
      'debt_amount': debtAmount,
      'debt_due_date': debtDueDate?.toIso8601String().split('T').first,
    })
        .select('id')
        .single();

    final saleId = saleData['id'] as String;

    final itemsJson = items.map((item) => item.toInsertJson(saleId)).toList();
    await _client.from('sale_items').insert(itemsJson);

    return saleId;
  }
}