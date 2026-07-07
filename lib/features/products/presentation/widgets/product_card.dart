import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;

  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary),
        ),
        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${product.size} • ${AppFormatters.currency(product.price)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: product.isActive,
              activeColor: AppColors.success,
              onChanged: (_) => onToggleActive(),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }
}
