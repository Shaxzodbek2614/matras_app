import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// TextField'ga raqam kiritilganda "1 000 000" ko'rinishida formatlaydi
class ThousandsInputFormatter extends TextInputFormatter {
  static final _fmt = NumberFormat.decimalPattern('uz');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }
    final formatted = _fmt.format(int.parse(digits));
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}