import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Ilova bo'ylab ishlatiladigan standart matn kiritish maydoni
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatter;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.inputFormatter,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.enabled = true,

  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: obscureText ? 1 : maxLines,
      inputFormatters: inputFormatter,
      obscureText: obscureText,
      onChanged: onChanged,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
