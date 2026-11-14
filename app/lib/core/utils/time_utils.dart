import 'package:intl/intl.dart';

String fmtTime(DateTime t) => DateFormat('H:mm').format(t);
String fmtDayHeader(DateTime d) => DateFormat('EEEE, d MMM').format(d);
String fmtShortDay(DateTime d) => DateFormat('EEE d MMM').format(d);
DateTime tomorrowDate([DateTime? now]) {
  final n = now ?? DateTime.now();
  return DateTime(n.year, n.month, n.day).add(const Duration(days: 1));
}

DateTime atTime(DateTime day, int hour, int minute) => DateTime(day.year, day.month, day.day, hour, minute);
