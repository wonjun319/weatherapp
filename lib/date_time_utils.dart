class DateTimeUtils {
  static String formatTime(int hour, int minute) {
    String period = hour < 12 ? '오전' : '오후';
    int displayHour = _getDisplayHour(hour);

    return '$period $displayHour:${minute.toString().padLeft(2, '0')}';
  }

  static String formatTimeFromString(String timeString) {
    if (timeString.length != 4) {
      return timeString;
    }

    int hour = int.parse(timeString.substring(0, 2));
    int minute = int.parse(timeString.substring(2));
    String period = hour < 12 ? '오전' : '오후';
    int displayHour = _getDisplayHour(hour);

    if (minute == 0) {
      return '$period $displayHour시';
    }

    return '$period $displayHour:${minute.toString().padLeft(2, '0')}';
  }

  static String getDayName(
      int index, String currentWeekday, List<String> weekdays) {
    int currentWeekdayIndex = weekdays.indexOf(currentWeekday);
    int targetWeekdayIndex = (currentWeekdayIndex + index) % 7;
    return weekdays[targetWeekdayIndex];
  }

  static int _getDisplayHour(int hour) {
    int displayHour = hour > 12 ? hour - 12 : hour;
    return displayHour == 0 ? 12 : displayHour;
  }
}
