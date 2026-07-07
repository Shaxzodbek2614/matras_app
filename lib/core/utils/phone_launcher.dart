import 'package:url_launcher/url_launcher.dart';

/// Telefon raqamini bosganda qurilmaning qo'ng'iroq qilish ekranini ochadi,
/// raqam avtomatik kiritilgan holda (qo'ng'iroq o'zi ketmaydi, foydalanuvchi
/// tugmani bosishi kerak — bu qurilma tizimining o'zi talab qiladigan xavfsizlik).
class PhoneLauncher {
  PhoneLauncher._();

  static Future<void> call(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) return;

    // Bo'sh joy, tire kabi belgilarni tozalab, faqat raqam va "+" qoldiramiz
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri(scheme: 'tel', path: cleaned);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
