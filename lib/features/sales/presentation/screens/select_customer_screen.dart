import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../customers/presentation/providers/customer_provider.dart';
import '../../../customers/presentation/widgets/customer_card.dart';
import '../providers/sale_provider.dart';
import 'add_sale_items_screen.dart';

/// Savdo jarayonining 1-qadami: mijozni tanlash
class SelectCustomerScreen extends StatefulWidget {
  const SelectCustomerScreen({super.key});

  @override
  State<SelectCustomerScreen> createState() => _SelectCustomerScreenState();
}

class _SelectCustomerScreenState extends State<SelectCustomerScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SaleProvider>().reset();
      context.read<CustomerProvider>().loadCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.selectCustomer)),
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
                    final results = provider.search(_query).where((c) => c.isActive).toList();
                    if (results.isEmpty) {
                      return const EmptyStateWidget(
                        message: AppStrings.noCustomers,
                        icon: Icons.people_outline,
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final customer = results[index];
                        return CustomerCard(
                          customer: customer,
                          onTap: () {
                            context.read<SaleProvider>().selectCustomer(customer);
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const AddSaleItemsScreen()),
                            );
                          },
                        );
                      },
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
