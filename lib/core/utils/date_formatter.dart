import 'package:intl/intl.dart';

class DateFormatter {
  static final _date = DateFormat('dd MMM yyyy');
  static final _dateTime = DateFormat('dd MMM yyyy, HH:mm');

  static String formatDate(DateTime dt) => _date.format(dt.toLocal());
  static String formatDateTime(DateTime dt) => _dateTime.format(dt.toLocal());

  static String communityEndLabel(DateTime endDate) {
    final now = DateTime.now();
    final diff = endDate.toLocal().difference(now);
    if (diff.isNegative) return 'Finalizada';
    if (diff.inDays == 0) return 'Termina hoy';
    if (diff.inDays == 1) return 'Termina mañana';
    return 'Termina en ${diff.inDays} días';
  }
}
