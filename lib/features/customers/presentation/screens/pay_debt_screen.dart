import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/thousands_input_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/services/telegram_service.dart';
import '../../../payments/data/repositories/payment_repository.dart';
import '../../data/models/customer_model.dart';

/// Mijoz qarzini to'lash ekrani. To'lov summasi mavjud qarzdan katta bo'lishi mumkin emas.
class PayDebtScreen extends StatefulWidget {
  final CustomerModel customer;
  const PayDebtScreen({super.key, required this.customer});

  @override
  State<PayDebtScreen> createState() => _PayDebtScreenState();
}

class _PayDebtScreenState extends State<PayDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _paymentDate = DateTime.now();
  bool _isSaving = false;

  final _repository = PaymentRepository();

  num _parse(String value) => num.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _paymentDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
   // final amount = num.parse(_amountController.text.replaceAll(' ', ''));
    final amount = _parse(_amountController.text);

    setState(() => _isSaving = true);
    try {
      await _repository.addPayment(
        customerId: widget.customer.id,
        amount: amount,
        paymentDate: _paymentDate,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );

      final chatId = widget.customer.telegramChatId;
      if (chatId != null) {
        final remainingDebt = widget.customer.totalDebt - amount;
        final message = TelegramService.buildPaymentMessage(
          date: DateTime.now(),
          paidAmount: amount,
          remainingDebt: remainingDebt,
        );
        await TelegramService.sendMessage(chatId: chatId.toString(), text: message);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
      showAppSnackBar(context, "To'lov muvaffaqiyatli saqlandi");
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      showAppSnackBar(context, e.toString(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxDebt = widget.customer.totalDebt;
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.payDebt)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.debt.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(AppStrings.currentDebt, style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(AppFormatters.currency(maxDebt), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.debt)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsInputFormatter()],
                decoration: const InputDecoration(labelText: AppStrings.paidAmount, suffixText: "so'm"),
                validator: (value) {
                  final amount = _parse(value!);
                  if (amount == null || amount <= 0) return "To'g'ri summa kiriting";
                  if (amount > maxDebt) return "Summa qarzdan katta bo'lishi mumkin emas";
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(14),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: AppStrings.paymentDate),
                  child: Text(AppFormatters.date(_paymentDate)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: AppStrings.note, alignLabelWithHint: true),
              ),
              const SizedBox(height: 28),
              CustomButton(
                label: AppStrings.save,
                isLoading: _isSaving,
                color: AppColors.success,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
