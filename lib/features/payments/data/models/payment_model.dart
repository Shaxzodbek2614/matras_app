class PaymentModel {
  final String id;
  final String customerId;
  final num amount;
  final DateTime paymentDate;
  final String? note;
  final DateTime createdAt;

  PaymentModel({
    required this.id,
    required this.customerId,
    required this.amount,
    required this.paymentDate,
    required this.note,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      amount: json['amount'] as num,
      paymentDate: DateTime.parse(json['payment_date'] as String),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
