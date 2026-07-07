import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../providers/customer_provider.dart';
import '../widgets/customer_card.dart';
import 'customer_profile_screen.dart';

class CustomersListScreen extends StatefulWidget {
  const CustomersListScreen({super.key});

  @override
  State<CustomersListScreen> createState() => _CustomersListScreenState();
}

class _CustomersListScreenState extends State<CustomersListScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerProvider>().loadCustomers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.customers)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: AppStrings.search,
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: Consumer<CustomerProvider>(
              builder: (context, provider, _) {
                switch (provider.status) {
                  case LoadStatus.initial:
                  case LoadStatus.loading:
                    return const LoadingWidget(message: AppStrings.loading);
                  case LoadStatus.error:
                    return AppErrorWidget(
                      message: provider.errorMessage ?? AppStrings.error,
                      onRetry: provider.loadCustomers,
                    );
                  case LoadStatus.loaded:
                    final results = provider.search(_query);
                    if (results.isEmpty) {
                      return const EmptyStateWidget(
                        message: AppStrings.noCustomers,
                        icon: Icons.people_outline,
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: provider.loadCustomers,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: results.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.debt.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Jami qarzdorlik', style: TextStyle(fontWeight: FontWeight.w600)),
                                  Text(
                                    AppFormatters.currency(provider.totalDebtAll),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.debt),
                                  ),
                                ],
                              ),
                            );
                          }
                          final customer = results[index - 1];
                          return CustomerCard(
                            customer: customer,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => CustomerProfileScreen(customerId: customer.id),
                              ),
                            ),
                            onToggleActive: (value) => provider.updateCustomer(customer.id, isActive: value),
                          );
                        },
                      ),
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}