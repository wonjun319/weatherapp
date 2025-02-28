import 'package:flutter/material.dart';

class AppTheme {
  static Color getBackgroundColor(Map<String, dynamic> liveData) {
    int currentTime = _getCurrentTime();
    int sunriseTime = _parseTime(liveData['sunset']?['sunrise'], '0600');
    int sunsetTime = _parseTime(liveData['sunset']?['sunset'], '1800');
    String sky = liveData['data']['sky'];

    Color weatherColor =
        _getTimeBasedColor(currentTime, sunriseTime, sunsetTime);
    return _adjustColorForWeather(weatherColor, sky);
  }

  static int _getCurrentTime() {
    DateTime now = DateTime.now();
    return now.hour * 100 + now.minute;
  }

  static int _parseTime(String? time, String defaultTime) {
    return int.parse(time ?? defaultTime);
  }

  static Color _getTimeBasedColor(
      int currentTime, int sunriseTime, int sunsetTime) {
    int beforeSunrise = sunriseTime - 100;
    int afterSunrise = sunriseTime + 100;
    int beforeSunset = sunsetTime - 100;
    int afterSunset = sunsetTime + 100;

    if (currentTime < beforeSunrise) return const Color(0xFF02144F); // 한밤중
    if (currentTime < sunriseTime) return const Color(0xFF072968); // 새벽
    if (currentTime < afterSunrise) return const Color(0xFF2598F7); // 이른 아침
    if (currentTime < (sunriseTime + 300)) return const Color(0xFF42A1FA); // 아침
    if (currentTime < (sunriseTime + 400))
      return const Color(0xFF309EF8); // 늦은 아침
    if (currentTime < (sunriseTime + 500)) return const Color(0xFF2BA4F5); // 오전
    if (currentTime < beforeSunset) return const Color(0xFF139DF8); // 한낮
    if (currentTime < sunsetTime) return const Color(0xFF108EF5); // 늦은 오후
    if (currentTime < afterSunset) return const Color(0xFF0F69B4); // 저녁
    if (currentTime < (sunsetTime + 200))
      return const Color(0xFF094D9A); // 늦은 저녁
    if (currentTime < (sunsetTime + 300)) return const Color(0xFF043B68); // 초저녁
    if (currentTime < (sunsetTime + 400)) return const Color(0xFF3434AA); // 밤
    if (currentTime < (sunsetTime + 500))
      return const Color(0xFF2A2A78); // 늦은 밤
    return const Color(0xFF12123A); // 심야
  }

  static Color _adjustColorForWeather(Color color, String sky) {
    switch (sky) {
      case '맑음':
        return color;
      case '구름많음':
        return Color.lerp(color, Colors.black, 0.2)!;
      case '흐림':
        return Color.lerp(color, Colors.black, 0.4)!;
      default:
        return color;
    }
  }
}
