import '../../../../core/services/supabase_service.dart';

/// payments jadvaliga yozish uchun repository.
/// Mijozning umumiy qarzi customers_summary VIEW orqali avtomatik qayta hisoblanadi,
/// shu sababli bu yerda qo'lda balans yangilash shart emas.
class PaymentRepository {
  final _client = SupabaseService.client;

  Future<void> addPayment({
    required String customerId,
    required num amount,
    required DateTime paymentDate,
    String? note,
  }) async {
    await _client.from('payments').insert({
      'customer_id': customerId,
      'amount': amount,
      'payment_date': paymentDate.toIso8601String(),
      'note': note,
    });
  }
}
