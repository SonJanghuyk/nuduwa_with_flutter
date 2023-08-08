import 'package:intl/intl.dart';

class FormatDateTime {

  static String simple(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(time.year, time.month, time.day);

    final todayFormat = DateFormat('a hh:mm');
    final notTodayFormat = DateFormat('MM월 dd일 a hh:mm');
    final notThisYearFormat = DateFormat('yyyy년 MM월 dd일 a hh:mm');

    if (today.compareTo(date) == 0) {
      // 오늘인 경우
      return todayFormat.format(time);
    } else if (now.year == date.year) {
      // 오늘이 아닌 경우
      return notTodayFormat.format(time);
    } else {
      // 올해가 아닌 경우
      return notThisYearFormat.format(time);
    }
  }
}