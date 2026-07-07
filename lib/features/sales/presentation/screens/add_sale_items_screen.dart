import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../products/data/models/product_model.dart';
import '../../../products/presentation/providers/product_provider.dart';
import '../../data/models/sale_item_model.dart';
import '../providers/sale_provider.dart';
import 'payment_step_screen.dart';

/// Savdo jarayonining 2-qadami: bir nechta mahsulot qo'shish.
/// Narx foydalanuvchi tomonidan kiritilmaydi — mahsulot narxidan avtomatik olinadi.
class AddSaleItemsScreen extends StatelessWidget {
  const AddSaleItemsScreen({super.key});

  Future<void> _openAddItemSheet(BuildContext context) async {
    final productProvider = context.read<ProductProvider>();
    final saleProvider = context.read<SaleProvider>();
    final products = await productProvider.loadActiveProducts();

    if (!context.mounted) return;

    if (products.isEmpty) {
      showAppSnackBar(context, "Faol mahsulotlar yo'q. Avval mahsulot qo'shing.", isError: true);
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddItemSheet(
        products: products,
        onAdd: (item) => saleProvider.addItem(item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.watch<SaleProvider>().selectedCustomer?.name ?? AppStrings.newSale)),
      body: Consumer<SaleProvider>(
        builder: (context, saleProvider, _) {
          if (saleProvider.items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 64, color: AppColors.textSecondary.withOpacity(0.4)),
                    const SizedBox(height: 16),
                    const Text("Hali mahsulot qo'shilmadi", style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () => _openAddItemSheet(context),
                      icon: const Icon(Icons.add),
                      label: const Text(AppStrings.addSaleItem),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: saleProvider.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = saleProvider.items[index];
              return Card(
                child: ListTile(
                  title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${AppFormatters.currency(item.price)} × ${item.quantity}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(AppFormatters.currency(item.total), style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.error, size: 20),
                        onPressed: () => saleProvider.removeItem(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Consumer<SaleProvider>(
        builder: (context, saleProvider, _) {
          if (saleProvider.items.isEmpty) return const SizedBox.shrink();
          return FloatingActionButton(
            onPressed: () => _openAddItemSheet(context),
            child: const Icon(Icons.add),
          );
        },
      ),
      bottomNavigationBar: Consumer<SaleProvider>(
        builder: (context, saleProvider, _) {
          final hasItems = saleProvider.items.isNotEmpty;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: ElevatedButton(
                onPressed: hasItems
                    ? () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const PaymentStepScreen()),
                        )
                    : null,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(AppStrings.next),
                    if (hasItems)
                      Text(
                        'Jami: ${AppFormatters.currency(saleProvider.grandTotal)}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AddItemSheet extends StatefulWidget {
  final List<ProductModel> products;
  final void Function(SaleItemDraft) onAdd;

  const _AddItemSheet({required this.products, required this.onAdd});

  @override
  State<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<_AddItemSheet> {
  ProductModel? _selected;
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final total = (_selected?.price ?? 0) * _quantity;
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          const Text(AppStrings.addSaleItem, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          DropdownButtonFormField<ProductModel>(
            value: _selected,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Mahsulot'),
            items: widget.products
                .map((p) => DropdownMenuItem(
                      value: p,
                      child: Text('${p.name} (${p.size}) — ${AppFormatters.currency(p.price)}'),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _selected = value),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(AppStrings.quantity, style: TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              IconButton.filledTonal(
                onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                icon: const Icon(Icons.remove),
              ),
              SizedBox(
                width: 40,
                child: Text('$_quantity', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              IconButton.filledTonal(
                onPressed: () => setState(() => _quantity++),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_selected != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(AppStrings.total, style: TextStyle(color: AppColors.textSecondary)),
                  Text(AppFormatters.currency(total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _selected == null
                ? null
                : () {
                    widget.onAdd(SaleItemDraft(
                      productId: _selected!.id,
                      productName: _selected!.name,
                      price: _selected!.price,
                      quantity: _quantity,
                    ));
                    Navigator.of(context).pop();
                  },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }
}
