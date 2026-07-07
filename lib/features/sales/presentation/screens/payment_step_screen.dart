import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/thousands_input_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../customers/presentation/providers/customer_provider.dart';
import '../providers/sale_provider.dart';

class PaymentStepScreen extends StatefulWidget {
  const PaymentStepScreen({super.key});

  @override
  State<PaymentStepScreen> createState() => _PaymentStepScreenState();
}

class _PaymentStepScreenState extends State<PaymentStepScreen> {
  late final TextEditingController _cashController;
  late final TextEditingController _debtController;
  bool _isUpdating = false;
  DateTime? _dueDate;
  String? _dueDateError;

  @override
  void initState() {
    super.initState();
    // Standart holat: hammasi nasiyaga yoziladi, naqd 0
    _cashController = TextEditingController(text: '0');
    _debtController = TextEditingController(text: AppFormatters.number(_grandTotal));
  }

  @override
  void dispose() {
    _cashController.dispose();
    _debtController.dispose();
    super.dispose();
  }

  num get _grandTotal => context.read<SaleProvider>().grandTotal;

  num _parse(String value) => num.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  void _onCashChanged(String value) {
    if (_isUpdating) return;
    _isUpdating = true;
    final cash = _parse(value).clamp(0, _grandTotal);
    final debt = _grandTotal - cash;
    _debtController.text = AppFormatters.number(debt);
    _isUpdating = false;
    setState(() {
      if (debt <= 0) _dueDate = null;
    });
  }

  void _onDebtChanged(String value) {
    if (_isUpdating) return;
    _isUpdating = true;
    final debt = _parse(value).clamp(0, _grandTotal);
    final cash = _grandTotal - debt;
    _cashController.text = AppFormatters.number(cash);
    _isUpdating = false;
    setState(() {
      if (debt <= 0) _dueDate = null;
    });
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
        _dueDateError = null;
      });
    }
  }

  Future<void> _save() async {
    final saleProvider = context.read<SaleProvider>();
    final cash = _parse(_cashController.text);
    final debt = _parse(_debtController.text);

    if (debt > 0 && _dueDate == null) {
      setState(() => _dueDateError = "Qaytarish sanasini tanlang");
      return;
    }

    final success = await saleProvider.saveSale(
      cashPaid: cash,
      debtAmount: debt,
      debtDueDate: debt > 0 ? _dueDate : null,
    );
    if (!mounted) return;

    if (success) {
      if (context.mounted) {
        // ignore: use_build_context_synchronously
        Provider.of<CustomerProvider>(context, listen: false).loadCustomers();
      }
      showAppSnackBar(context, AppStrings.saleSaved);
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      showAppSnackBar(context, saleProvider.errorMessage ?? AppStrings.error, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final grandTotal = context.watch<SaleProvider>().grandTotal;
    final isSaving = context.watch<SaleProvider>().isSaving;
    final currentDebt = _parse(_debtController.text);

    return Scaffold(
      appBar: AppBar(title: const Text('To\'lov')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(AppStrings.grandTotal, style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    AppFormatters.currency(grandTotal),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _cashController,
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsInputFormatter()],
              onChanged: _onCashChanged,
              decoration: const InputDecoration(
                labelText: AppStrings.cashPaid,
                prefixIcon: Icon(Icons.payments_outlined, color: AppColors.cash),
                suffixText: "so'm",
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _debtController,
              keyboardType: TextInputType.number,
              inputFormatters: [ThousandsInputFormatter()],
              onChanged: _onDebtChanged,
              decoration: const InputDecoration(
                labelText: AppStrings.debtAmount,
                prefixIcon: Icon(Icons.receipt_long_outlined, color: AppColors.debt),
                suffixText: "so'm",
              ),
            ),
            if (currentDebt > 0) ...[
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDueDate,
                borderRadius: BorderRadius.circular(14),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: "Qarzni qaytarish sanasi",
                    prefixIcon: const Icon(Icons.event_outlined, color: AppColors.debt),
                    errorText: _dueDateError,
                  ),
                  child: Text(_dueDate == null ? "Sanani tanlang" : AppFormatters.date(_dueDate!)),
                ),
              ),
            ],
            const SizedBox(height: 32),
            CustomButton(
              label: AppStrings.save,
              isLoading: isSaving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}