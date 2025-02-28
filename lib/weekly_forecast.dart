import 'package:flutter/material.dart';
import 'dart:math';
import 'weather_utils.dart';
import 'date_time_utils.dart';

class WeeklyForecast extends StatelessWidget {
  final Map<String, dynamic>? weeklyData;

  const WeeklyForecast({super.key, required this.weeklyData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: _buildWeeklyForecastRows(),
      ),
    );
  }

  List<Widget> _buildWeeklyForecastRows() {
    final List<String> weekdays = [
      '월요일',
      '화요일',
      '수요일',
      '목요일',
      '금요일',
      '토요일',
      '일요일'
    ];
    final DateTime now = DateTime.now();
    final String currentWeekday = weekdays[now.weekday - 1];

    return List.generate(
      weeklyData?['data']?.length ?? 0,
      (index) {
        final dayData = weeklyData?['data'][index];
        String dayName = _getDayName(index, currentWeekday, weekdays);
        String precipitation = _getPrecipitation(dayData);

        IconData amSkyIcon =
            WeatherUtils.getAmWeatherIcon(dayData?['am_sky_status']);
        IconData pmSkyIcon =
            WeatherUtils.getPmWeatherIcon(dayData?['pm_sky_status']);
        IconData weatherIcon = WeatherUtils.getWatherIcon(max<num>(
            dayData?['am_rain_prob'] ?? 0, dayData?['pm_rain_prob'] ?? 0));

        return _buildForecastRow(
            dayName, precipitation, amSkyIcon, pmSkyIcon, weatherIcon, dayData);
      },
    );
  }

  String _getDayName(int index, String currentWeekday, List<String> weekdays) {
    return index == 0
        ? '오늘'
        : DateTimeUtils.getDayName(index, currentWeekday, weekdays);
  }

  String _getPrecipitation(Map<String, dynamic>? dayData) {
    return dayData != null
        ? '${max<num>(dayData['am_rain_prob'] ?? 0, dayData['pm_rain_prob'] ?? 0)}%'
        : 'N/A';
  }

  Widget _buildForecastRow(
      String dayName,
      String precipitation,
      IconData amSkyIcon,
      IconData pmSkyIcon,
      IconData weatherIcon,
      Map<String, dynamic>? dayData) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              dayName,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(weatherIcon,
                    color: const Color.fromARGB(209, 255, 255, 255), size: 20),
                SizedBox(
                  width: 35,
                  child: Text(
                    precipitation,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 15),
                Icon(amSkyIcon, color: Colors.white, size: 20),
                const SizedBox(width: 5),
                Icon(pmSkyIcon, color: Colors.white, size: 20),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${dayData?['max_temp'] ?? 'N/A'}° ${dayData?['min_temp'] ?? 'N/A'}°',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
