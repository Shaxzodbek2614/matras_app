/// Forma maydonlari uchun validatsiya funksiyalari
class Validators {
  Validators._();

 static num _parse(String value) => num.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;


  static String? required(String? value, {String message = "Bu maydon to'ldirilishi shart"}) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? positiveNumber(String? value, {String message = "To'g'ri son kiriting"}) {
    if (value == null || value.trim().isEmpty) return message;
    final parsed = _parse(value);
    if (parsed == null || parsed <= 0) return message;
    return null;
  }

  static String? nonNegativeNumber(String? value, {String message = "To'g'ri son kiriting"}) {
    if (value == null || value.trim().isEmpty) return message;
    final parsed = _parse(value);
    if (parsed == null || parsed < 0) return message;
    return null;
  }
}
