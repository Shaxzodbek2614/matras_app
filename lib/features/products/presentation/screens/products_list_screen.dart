import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import 'add_edit_product_screen.dart';

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({super.key});

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.products)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.addProduct),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          switch (provider.status) {
            case LoadStatus.initial:
            case LoadStatus.loading:
              return const LoadingWidget(message: AppStrings.loading);
            case LoadStatus.error:
              return AppErrorWidget(
                message: provider.errorMessage ?? AppStrings.error,
                onRetry: provider.loadProducts,
              );
            case LoadStatus.loaded:
              if (provider.products.isEmpty) {
                return const EmptyStateWidget(
                  message: AppStrings.noProducts,
                  icon: Icons.inventory_2_outlined,
                );
              }
              return RefreshIndicator(
                onRefresh: provider.loadProducts,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                  itemCount: provider.products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final product = provider.products[index];
                    return ProductCard(
                      product: product,
                      onToggleActive: () => provider.toggleActive(product),
                      onEdit: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => AddEditProductScreen(product: product)),
                      ),
                    );
                  },
                ),
              );
          }
        },
      ),
    );
  }
}
