import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/thousands_input_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_textfield.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../data/models/product_model.dart';
import '../providers/product_provider.dart';

class AddEditProductScreen extends StatefulWidget {
  final ProductModel? product;
  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _sizeController;
  late final TextEditingController _priceController;
  bool _isSaving = false;

  bool get isEditing => widget.product != null;
  num _parse(String value) => num.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;


  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _sizeController = TextEditingController(text: widget.product?.size ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toStringAsFixed(0) ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sizeController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final provider = context.read<ProductProvider>();
    final name = _nameController.text.trim();
    final size = _sizeController.text.trim();
    final price = _parse(_priceController.text);

    final success = isEditing
        ? await provider.updateProduct(widget.product!.id, name: name, size: size, price: price)
        : await provider.addProduct(name: name, size: size, price: price);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.of(context).pop();
      showAppSnackBar(context, isEditing ? "Mahsulot yangilandi" : "Mahsulot qo'shildi");
    } else {
      showAppSnackBar(context, provider.errorMessage ?? AppStrings.error, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? AppStrings.editProduct : AppStrings.addProduct)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _nameController,
                label: AppStrings.productName,
                validator: Validators.required,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _sizeController,
                label: AppStrings.productSize,
                hint: "Masalan: 160x200 sm",
                validator: Validators.required,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _priceController,
                label: AppStrings.productPrice,
                keyboardType: TextInputType.number,
                inputFormatter: [ThousandsInputFormatter()],
                validator: Validators.positiveNumber,
                suffixIcon: const Padding(
                  padding: EdgeInsets.only(right: 12, top: 14),
                  child: Text("so'm"),
                ),
              ),
              const SizedBox(height: 28),
              CustomButton(
                label: AppStrings.save,
                isLoading: _isSaving,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
