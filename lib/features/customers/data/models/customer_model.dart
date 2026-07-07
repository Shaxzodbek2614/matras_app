class CustomerModel {
  final String id;
  final int? telegramChatId;
  final String name;
  final String? telegramUsername;
  final String? phoneNumber;
  final DateTime createdAt;
  final bool isActive;

  final num totalPurchases;
  final num totalPaid;

  CustomerModel({
    required this.id,
    required this.telegramChatId,
    required this.name,
    required this.telegramUsername,
    required this.phoneNumber,
    required this.createdAt,
    this.isActive = true,
    this.totalPurchases = 0,
    this.totalPaid = 0,
  });

  num get totalDebt => totalPurchases - totalPaid;

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      telegramChatId: json['telegram_chat_id'] as int?,
      name: json['name'] as String? ?? "Noma'lum mijoz",
      telegramUsername: json['telegram_username'] as String?,
      phoneNumber: json['phone_number'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
      totalPurchases: (json['total_purchases'] as num?) ?? 0,
      totalPaid: (json['total_paid'] as num?) ?? 0,
    );
  }
}