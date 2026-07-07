/// Bitta savdo ichidagi bitta mahsulot qatorini vaqtincha (UI darajasida) ifodalaydi.
/// Bazaga yozilishidan oldin savdo savati (cart) sifatida ishlatiladi.
class SaleItemDraft {
  final String productId;
  final String productName;
  final num price;
  final int quantity;

  SaleItemDraft({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  num get total => price * quantity;

  Map<String, dynamic> toInsertJson(String saleId) {
    return {
      'sale_id': saleId,
      'product_id': productId,
      'price': price,
      'quantity': quantity,
      'total': total,
    };
  }
}
