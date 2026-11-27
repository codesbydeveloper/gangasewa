import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class Formatters {
  Formatters._();

  static final _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: AppConstants.currencySymbol,
    decimalDigits: 0,
  );

  static final _currencyDecimal = NumberFormat.currency(
    locale: 'en_IN',
    symbol: AppConstants.currencySymbol,
    decimalDigits: 2,
  );

  static final _date = DateFormat('dd MMM yyyy');
  static final _dateShort = DateFormat('dd MMM');
  static final _time = DateFormat('hh:mm a');
  static final _dateTime = DateFormat('dd MMM yyyy, hh:mm a');
  static final _dayDate = DateFormat('EEE, dd MMM');

  static String currency(num amount, {bool decimals = false}) {
    return decimals ? _currencyDecimal.format(amount) : _currency.format(amount);
  }

  static String date(DateTime d) => _date.format(d);
  static String dateShort(DateTime d) => _dateShort.format(d);
  static String time(DateTime d) => _time.format(d);
  static String dateTime(DateTime d) => _dateTime.format(d);
  static String dayDate(DateTime d) => _dayDate.format(d);

  static String duration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  static String maskPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) return phone;
    final last2 = digits.substring(digits.length - 2);
    final first2 = digits.length > 8 ? digits.substring(0, 2) : '';
    return '+91 $first2******$last2';
  }

  static String maskAccount(String account) {
    if (account.length < 4) return '••••';
    return '•••• ${account.substring(account.length - 4)}';
  }

  static String maskUpi(String upi) {
    final parts = upi.split('@');
    if (parts.length != 2) return upi;
    final name = parts[0];
    final masked = name.length <= 4
        ? '${name[0]}****'
        : '${name.substring(0, 4)}****';
    return '$masked@${parts[1]}';
  }

  static String percentChange(double value) {
    final sign = value >= 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(1)}%';
  }
}
