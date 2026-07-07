import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/customer_model.dart';

class CustomerCard extends StatelessWidget {
  final CustomerModel customer;
  final VoidCallback onTap;
  final ValueChanged<bool>? onToggleActive; // null bo'lsa switch ko'rinmaydi

  const CustomerCard({
    super.key,
    required this.customer,
    required this.onTap,
    this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    final hasDebt = customer.totalDebt > 0;
    return Opacity(
      opacity: customer.isActive ? 1 : 0.5,
      child: Card(
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(
            [
              if (customer.telegramUsername != null) '@${customer.telegramUsername}',
              if (customer.phoneNumber != null) customer.phoneNumber!,
              if (!customer.isActive) 'Nofaol',
            ].join(' • '),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                hasDebt ? AppFormatters.currency(customer.totalDebt) : "Qarzi yo'q",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: hasDebt ? AppColors.debt : AppColors.success,
                ),
              ),
              // if (onToggleActive != null)
              //   Switch(
              //     value: customer.isActive,
              //     activeColor: AppColors.success,
              //     onChanged: onToggleActive,
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}