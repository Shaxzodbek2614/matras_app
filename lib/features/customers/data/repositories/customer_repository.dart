import '../../../../core/services/supabase_service.dart';
import '../models/customer_model.dart';

/// customers jadvali bilan ishlash uchun repository.
/// Qarzdorlik hisobini to'g'ri olish uchun `customers_summary` nomli SQL VIEW
/// ishlatiladi (supabase/sql/schema.sql faylida yaratilgan).
class CustomerRepository {
  final _client = SupabaseService.client;

  Future<List<CustomerModel>> getAllCustomers() async {
    final data = await _client
        .from('customers_summary')
        .select()
        .order('created_at', ascending: false);
    return (data as List).map((e) => CustomerModel.fromJson(e)).toList();
  }

  Future<CustomerModel> getCustomerById(String id) async {
    final data = await _client.from('customers_summary').select().eq('id', id).single();
    return CustomerModel.fromJson(data);
  }

  Future<List<Map<String, dynamic>>> getCustomerSales(String customerId) async {
    final data = await _client
        .from('sales')
        .select('*, sale_items(*, products(name))')
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getCustomerPayments(String customerId) async {
    final data = await _client
        .from('payments')
        .select()
        .eq('customer_id', customerId)
        .order('payment_date', ascending: false);
    return (data as List).cast<Map<String, dynamic>>();
  }

  Future<void> updateCustomer(String id, {String? name, String? phoneNumber,bool? isActive}) async {
    final changes = <String, dynamic>{};
    if (name != null) changes['name'] = name;
    if (phoneNumber != null) changes['phone_number'] = phoneNumber;
    if (isActive != null) changes['is_active'] = isActive;
    if (changes.isEmpty) return;
    await _client.from('customers').update(changes).eq('id', id);
  }
}
