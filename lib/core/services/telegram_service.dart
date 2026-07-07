import 'dart:convert';
import 'package:http/http.dart' as http;

/// Telegram Bot API orqali mijozlarga xabar yuborish uchun servis.
/// Bot @AudioHisobotBot kabi @BotFather orqali yaratilgan botingiz bo'lishi kerak.
class TelegramService {
  TelegramService._();

  // TODO: BotFather'dan olingan bot tokenini shu yerga kiriting.
  static const String botToken = '8924804915:AAEiZO-Gc_R-u85Qq-4_z5ghITtdQEQjmKw';

  static String get _baseUrl => 'https://api.telegram.org/bot$botToken';

  /// Berilgan chat_id ga xabar yuborish. Chat ID customers jadvalida saqlanadi
  /// (mijoz botga /start yuborganda Edge Function orqali yoziladi).
  static Future<bool> sendMessage({
    required String chatId,
    required String text,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/sendMessage');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'chat_id': chatId,
          'text': text,
          'parse_mode': 'HTML',
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      // Telegram xabari yuborilmasa ham savdo/to'lov saqlanishi to'xtamasligi kerak,
      // shuning uchun xatolikni log qilib, false qaytaramiz.
      // ignore: avoid_print
      print('Telegram xabar yuborishda xatolik: $e');
      return false;
    }
  }

  /// Savdo tugagach mijozga yuboriladigan xabarni shakllantiradi
  static String buildSaleMessage({
    required DateTime date,
    required List<Map<String, dynamic>> items, // {name, price, qty, total}
    required num grandTotal,
    required num cash,
    required num debt,
    required num totalDebtAfter,
    DateTime? debtDueDate
  }) {
    final dateStr = '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    final debtStr = '${debtDueDate?.day.toString().padLeft(2, '0')}.${debtDueDate?.month.toString().padLeft(2, '0')}.${debtDueDate?.year}';
    final timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    final buffer = StringBuffer();
    buffer.writeln('🧾 <b>Xaridingiz muvaffaqiyatli saqlandi.</b>\n');
    buffer.writeln('📅 Sana: $dateStr');
    buffer.writeln('🕒 Vaqt: $timeStr\n');
    buffer.writeln('<b>Mahsulotlar:</b>\n');
    for (final item in items) {
      buffer.writeln('• ${item['name']}');
      buffer.writeln('  Narxi: ${_fmt(item['price'])}');
      buffer.writeln('  Soni: ${item['qty']}');
      buffer.writeln('  Jami: ${_fmt(item['total'])}\n');
    }
    buffer.writeln('—————————————\n');
    buffer.writeln('Umumiy summa: ${_fmt(grandTotal)} so\'m');
    buffer.writeln('Naqd: ${_fmt(cash)} so\'m');
    buffer.writeln('Nasiya: ${_fmt(debt)} so\'m\n');
    if(debtDueDate!=null){
      buffer.writeln('📅 Qaytarish vaqti: $debtStr');
    }
    buffer.writeln('💳 <b>Umumiy qarzdorligingiz: ${_fmt(totalDebtAfter)} so\'m</b>\n');
    buffer.writeln('Xaridingiz uchun rahmat.');
    return buffer.toString();
  }

  /// To'lov qabul qilingach yuboriladigan xabar
  static String buildPaymentMessage({
    required DateTime date,
    required num paidAmount,
    required num remainingDebt,
  }) {
    final dateStr = '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    final timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    final buffer = StringBuffer();
    buffer.writeln('💰 <b>To\'lov qabul qilindi.</b>\n');
    buffer.writeln('📅 Sana: $dateStr');
    buffer.writeln('🕒 Vaqt: $timeStr\n');
    buffer.writeln('To\'langan summa: ${_fmt(paidAmount)} so\'m\n');

    if (remainingDebt <= 0) {
      buffer.writeln('✅ <b>Tabriklaymiz!</b>\n');
      buffer.writeln('Sizning barcha qarzingiz to\'liq yopildi.\n');
      buffer.writeln('Hamkorligingiz uchun rahmat!');
    } else {
      buffer.writeln('Qolgan qarzingiz: ${_fmt(remainingDebt)} so\'m\n');
      buffer.writeln('To\'lovingiz uchun rahmat!');
    }
    return buffer.toString();
  }

  static String _fmt(num value) {
    final s = value.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }
}
