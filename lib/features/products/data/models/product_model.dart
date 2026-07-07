class ProductModel {
  final String id;
  final String name;
  final String size;
  final num price;
  final bool isActive;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.size,
    required this.price,
    required this.isActive,
    required this.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      size: json['size'] as String? ?? '',
      price: json['price'] as num,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'name': name,
      'size': size,
      'price': price,
      'is_active': isActive,
    };
  }

  ProductModel copyWith({
    String? name,
    String? size,
    num? price,
    bool? isActive,
  }) {
    return ProductModel(
      id: id,
      name: name ?? this.name,
      size: size ?? this.size,
      price: price ?? this.price,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}
