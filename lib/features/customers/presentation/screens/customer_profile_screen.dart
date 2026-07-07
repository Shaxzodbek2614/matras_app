import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/phone_launcher.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../data/models/customer_model.dart';
import '../../data/repositories/customer_repository.dart';
import '../providers/customer_provider.dart';
import 'pay_debt_screen.dart';

class CustomerProfileScreen extends StatefulWidget {
  final String customerId;
  const CustomerProfileScreen({super.key, required this.customerId});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final _repository = CustomerRepository();

  CustomerModel? _customer;
  List<Map<String, dynamic>> _sales = [];
  List<Map<String, dynamic>> _payments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _repository.getCustomerById(widget.customerId),
        _repository.getCustomerSales(widget.customerId),
        _repository.getCustomerPayments(widget.customerId),
      ]);
      if (!mounted) return;
      setState(() {
        _customer = results[0] as CustomerModel;
        _sales = results[1] as List<Map<String, dynamic>>;
        _payments = results[2] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        print("Xatolik: ${_error}");
        _isLoading = false;
      });
    }
  }

  Future<void> _editName() async {
    final controllerName = TextEditingController(text: _customer!.name);
    final controllerPhoneNumber = TextEditingController(text: _customer!.phoneNumber);
    String newName = controllerName.text.toString();
    String newPhoneNumber = controllerPhoneNumber.text.toString();
    await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Ma'lumotni tahrirlash"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controllerName,
              autofocus: true,
              decoration: const InputDecoration(labelText: AppStrings.customerName),
            ),
            SizedBox(height: 10,),
            TextField(
              controller: controllerPhoneNumber,
              autofocus: true,
              decoration: const InputDecoration(labelText: AppStrings.customerPhoneNumber),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text(AppStrings.cancel)),
          FilledButton(
            onPressed: () {
              newPhoneNumber = controllerPhoneNumber.text.toString();
              newName = controllerName.text.toString();
              Navigator.pop(context);
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
    if (newName.isEmpty || !mounted || newPhoneNumber.isEmpty) return;
    final provider = Provider.of<CustomerProvider>(context, listen: false);
    final ok = await provider.updateCustomer(widget.customerId, name: newName,phoneNumber: newPhoneNumber);
    if (!mounted) return;
    if (ok) {
      _load();
      showAppSnackBar(context, "Ma'lumotni yangilandi");
    } else {
      showAppSnackBar(context, provider.errorMessage ?? AppStrings.error, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_customer?.name ?? '...'),
            InkWell(
              onTap: () => PhoneLauncher.call(_customer?.phoneNumber),
              child: Text(
                _customer?.phoneNumber ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _customer == null ? null : _editName,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: AppStrings.loading)
          : _error != null
              ? AppErrorWidget(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      _buildSummaryCard(),
                      const SizedBox(height: 24),
                      const Text(AppStrings.purchaseHistory, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      if (_sales.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: EmptyStateWidget(message: 'Xaridlar tarixi bo\'sh', icon: Icons.shopping_bag_outlined),
                        )
                      else
                        ..._sales.map(_buildSaleTile),
                      const SizedBox(height: 24),
                      const Text(AppStrings.paymentHistory, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      if (_payments.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: EmptyStateWidget(message: 'To\'lovlar tarixi bo\'sh', icon: Icons.receipt_outlined),
                        )
                      else
                        ..._payments.map(_buildPaymentTile),
                    ],
                  ),
                ),
      floatingActionButton: (_customer != null && _customer!.totalDebt > 0)
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => PayDebtScreen(customer: _customer!)),
                );
                if (result == true) _load();
              },
              icon: const Icon(Icons.payments_outlined),
              label: const Text(AppStrings.payDebt),
              backgroundColor: AppColors.success,
            )
          : null,
    );
  }

  Widget _buildSummaryCard() {
    final customer = _customer!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _summaryRow(AppStrings.totalPurchases, AppFormatters.currency(customer.totalPurchases)),
            const Divider(height: 20),
            _summaryRow(AppStrings.totalPaid, AppFormatters.currency(customer.totalPaid)),
            const Divider(height: 20),
            _summaryRow(
              AppStrings.currentDebt,
              AppFormatters.currency(customer.totalDebt),
              valueColor: customer.totalDebt > 0 ? AppColors.debt : AppColors.success,
              bold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor, bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            fontSize: bold ? 17 : 15,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSaleTile(Map<String, dynamic> sale) {
    // Supabase UTC (timestamptz) qaytaradi — .toLocal() bilan telefon vaqtiga o'giramiz
    final date = DateTime.parse(sale['created_at'] as String).toLocal();
    final items = (sale['sale_items'] as List?) ?? [];
    final debtAmount = (sale['debt_amount'] as num?) ?? 0;
    final dueDateRaw = sale['debt_due_date'] as String?;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(AppFormatters.currency(sale['grand_total'] as num)),
        subtitle: Text(AppFormatters.dateTime(date)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${item['products']?['name'] ?? ''} × ${item['quantity']}'),
                  Text(AppFormatters.currency(item['total'] as num)),
                ],
              ),
            ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Naqd', style: TextStyle(color: AppColors.cash)),
              Text(AppFormatters.currency(sale['cash_paid'] as num)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Nasiya', style: TextStyle(color: AppColors.debt)),
              Text(AppFormatters.currency(debtAmount)),
            ],
          ),
          if (debtAmount > 0 && dueDateRaw != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Qaytarish sanasi', style: TextStyle(color: AppColors.textSecondary)),
                Text(
                  AppFormatters.date(DateTime.parse(dueDateRaw)),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentTile(Map<String, dynamic> payment) {
    final date = DateTime.parse(payment['payment_date'] as String);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.check_circle_outline, color: AppColors.success),
        title: Text(AppFormatters.currency(payment['amount'] as num)),
        subtitle: Text(
          [AppFormatters.date(date), if (payment['note'] != null && (payment['note'] as String).isNotEmpty) payment['note']].join(' • '),
        ),
      ),
    );
  }
}
