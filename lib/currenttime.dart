import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'weather_utils.dart';
import 'date_time_utils.dart';
import 'package:timezone/data/latest.dart' as tz;

class CurrentWeather extends StatelessWidget {
  final Map<String, dynamic>? liveData;

  const CurrentWeather({
    super.key,
    required this.liveData,
  });

  @override
  Widget build(BuildContext context) {
    tz.initializeTimeZones();
    final koreanLocation = tz.getLocation('Asia/Seoul');
    final now = tz.TZDateTime.now(koreanLocation);
    final currentWeekday = _getCurrentWeekday(now);
    final currentTime = _getCurrentTime();
    final sunriseTime = _getSunriseTime();
    final sunsetTime = _getSunsetTime();
    final weatherIcon = _getWeatherIcon(currentTime, sunriseTime, sunsetTime);

    return Row(
      children: [
        _buildTemperatureText(),
        const SizedBox(width: 20),
        _buildWeatherDetails(currentWeekday, now),
        const Spacer(),
        Icon(weatherIcon, color: Colors.white, size: 82),
        const SizedBox(width: 10),
      ],
    );
  }

  String _getCurrentWeekday(tz.TZDateTime now) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[now.weekday - 1];
  }

  int _getCurrentTime() {
    final now = DateTime.now();
    return now.hour * 100 + now.minute;
  }

  int _getSunriseTime() {
    return int.parse(liveData?['sunset']?['sunrise'] ?? '0600');
  }

  int _getSunsetTime() {
    return int.parse(liveData?['sunset']?['sunset'] ?? '1800');
  }

  IconData _getWeatherIcon(int currentTime, int sunriseTime, int sunsetTime) {
    if (currentTime >= sunriseTime && currentTime < sunsetTime) {
      return WeatherUtils.getAmWeatherIcon(liveData?['data']['sky']);
    } else {
      return WeatherUtils.getPmWeatherIcon(liveData?['data']['sky']);
    }
  }

  Widget _buildTemperatureText() {
    return Text(
      "${liveData?['data']['temp']}°",
      style: const TextStyle(
        color: Colors.white,
        fontSize: 60,
        fontWeight: FontWeight.w300,
      ),
    );
  }

  Widget _buildWeatherDetails(String currentWeekday, tz.TZDateTime now) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${liveData?['data']['maxTemp']}° / ${liveData?['data']['minTemp']}°",
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        Text(
          "${liveData?['data']['sky']}",
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        Text(
          '$currentWeekday, ${DateTimeUtils.formatTime(now.hour, now.minute)}',
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }
}
