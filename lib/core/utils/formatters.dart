import 'package:intl/intl.dart';

/// Narx va sana formatlash uchun yordamchi funksiyalar
class AppFormatters {
  AppFormatters._();

  static final _currencyFormat = NumberFormat.decimalPattern('uz');
  static final _dateFormat = DateFormat('dd.MM.yyyy');
  static final _timeFormat = DateFormat('HH:mm');
  static final _dateTimeFormat = DateFormat('dd.MM.yyyy HH:mm');

  static String currency(num value) => "${_currencyFormat.format(value)} so'm";

  static String number(num value) => _currencyFormat.format(value);

  static String date(DateTime date) => _dateFormat.format(date);

  static String time(DateTime date) => _timeFormat.format(date);

  static String dateTime(DateTime date) => _dateTimeFormat.format(date);
}
