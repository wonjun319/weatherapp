import 'package:flutter/material.dart';
import 'dart:math';
import 'weather_utils.dart';
import 'date_time_utils.dart';

class HourlyForecast extends StatelessWidget {
  final Map<String, dynamic>? dailyData;

  const HourlyForecast({super.key, required this.dailyData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildHourlyForecasts(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildHourlyForecasts() {
    List<Map<String, dynamic>> originalData =
        List.from(dailyData?['data'] ?? []);
    String? sunrise = dailyData?['sunset']?['sunrise'];
    String? sunset = dailyData?['sunset']?['sunset'];

    int startTime = int.parse(originalData.first['time']);
    int? sunriseTime = _adjustTime(sunrise, startTime);
    int? sunsetTime = _adjustTime(sunset, startTime);

    int sunriseIndex = _findInsertIndex(originalData, sunriseTime, startTime);
    int sunsetIndex =
        _findInsertIndex(originalData, sunsetTime, startTime, sunriseIndex);

    if (sunrise != null) {
      originalData.insert(
          sunriseIndex, _createSunEventData(sunrise, 'sunrise'));
    }

    if (sunset != null) {
      originalData.insert(sunsetIndex, _createSunEventData(sunset, 'sunset'));
    }

    final List<double> allTemperatures = _extractTemperatures(originalData);

    return List.generate(originalData.length, (index) {
      final hourData = originalData[index];
      return _buildHourlyForecastItem(
        hourData: hourData,
        allTemperatures: allTemperatures,
        index: index,
        sortedData: originalData,
      );
    });
  }

  int? _adjustTime(String? time, int startTime) {
    if (time == null) return null;
    int adjustedTime = int.parse(time);
    if (adjustedTime < startTime) adjustedTime += 2400;
    return adjustedTime;
  }

  int _findInsertIndex(
      List<Map<String, dynamic>> data, int? eventTime, int startTime,
      [int offset = 0]) {
    if (eventTime == null) return data.length;
    int index = data.indexWhere((d) {
      int currentTime = int.parse(d['time']);
      if (currentTime < startTime) currentTime += 2400;
      return currentTime > eventTime;
    });
    return index == -1 ? data.length : index + offset;
  }

  Map<String, dynamic> _createSunEventData(String time, String type) {
    return {
      'time': time,
      'type': type,
      'temp': null,
      'sky': type,
      'rain_prob': null,
    };
  }

  List<double> _extractTemperatures(List<Map<String, dynamic>> data) {
    return data
        .where((d) => d['type'] != 'sunrise' && d['type'] != 'sunset')
        .map((d) => (d['temp'] ?? 0).toDouble())
        .toList()
        .cast<double>();
  }

  Widget _buildHourlyForecastItem({
    required Map<String, dynamic> hourData,
    required List<double> allTemperatures,
    required int index,
    required List<Map<String, dynamic>> sortedData,
  }) {
    const itemWidth = 56.0;
    final totalWidth = allTemperatures.length * itemWidth;

    String timeText = hourData['time'] != null
        ? DateTimeUtils.formatTimeFromString(hourData['time'])
        : '';

    String temperatureText = _getTemperatureText(hourData);
    IconData weatherIcon = _getWeatherIcon(hourData);

    String precipitationText = _getPrecipitationText(hourData);
    num precipitationValue = _getPrecipitationValue(hourData);
    IconData waterIcon = WeatherUtils.getWatherIcon(precipitationValue);

    return Container(
      width: 40,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Text(
            timeText,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            softWrap: false,
            overflow: TextOverflow.visible,
          ),
          const SizedBox(height: 8),
          Icon(
            weatherIcon,
            color: Colors.white,
            size: 30,
          ),
          const SizedBox(height: 8),
          Text(
            temperatureText,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          if (index == 0)
            SizedBox(
              height: 30,
              width: totalWidth,
              child: CustomPaint(
                painter: TemperatureLinePainter(
                  data: sortedData,
                  maxTemp: allTemperatures.reduce(max),
                  minTemp: allTemperatures.reduce(min),
                  itemWidth: itemWidth,
                ),
              ),
            ),
          if (precipitationText.isNotEmpty) ...[
            SizedBox(height: index == 0 ? 4 : 34),
            Row(
              children: [
                Icon(waterIcon,
                    color: const Color.fromARGB(209, 255, 255, 255), size: 15),
                Text(
                  precipitationText,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            )
          ],
        ],
      ),
    );
  }

  String _getTemperatureText(Map<String, dynamic> hourData) {
    if (hourData['type'] == 'sunrise') {
      return '일출';
    } else if (hourData['type'] == 'sunset') {
      return '일몰';
    } else if (hourData['temp'] != null) {
      return '${hourData['temp']}°';
    }
    return '';
  }

  IconData _getWeatherIcon(Map<String, dynamic> hourData) {
    String skyCondition = hourData['sky'] ?? '';
    int currentTime = int.parse(hourData['time']);
    int sunriseTime = int.parse(dailyData?['sunset']?['sunrise'] ?? '0600');
    int sunsetTime = int.parse(dailyData?['sunset']?['sunset'] ?? '1800');

    if (currentTime < sunriseTime && currentTime + 2400 > sunsetTime) {
      currentTime += 2400;
    }
    if (sunsetTime < sunriseTime) {
      sunsetTime += 2400;
    }

    if (currentTime >= sunriseTime && currentTime < sunsetTime) {
      return WeatherUtils.getAmWeatherIcon(skyCondition);
    } else {
      return WeatherUtils.getPmWeatherIcon(skyCondition);
    }
  }

  String _getPrecipitationText(Map<String, dynamic> hourData) {
    if (hourData['type'] == 'sunrise' || hourData['type'] == 'sunset') {
      return '';
    } else if (hourData['rain_prob'] != null) {
      return '${hourData['rain_prob']}%';
    }
    return '';
  }

  num _getPrecipitationValue(Map<String, dynamic> hourData) {
    if (hourData['type'] == 'sunrise' || hourData['type'] == 'sunset') {
      return 0;
    }
    return hourData['rain_prob'] ?? 0;
  }
}

class TemperatureLinePainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double maxTemp;
  final double minTemp;
  final double itemWidth;

  TemperatureLinePainter({
    required this.data,
    required this.maxTemp,
    required this.minTemp,
    required this.itemWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    double? lastX;
    double? lastY;
    bool isFirstPoint = true;

    for (var i = 0; i < data.length; i++) {
      final item = data[i];
      if (item['type'] != 'sunrise' &&
          item['type'] != 'sunset' &&
          item['temp'] != null) {
        final tempRange = maxTemp - minTemp;
        final normalizedTemp = (item['temp'].toDouble() - minTemp) / tempRange;
        final x = (i * itemWidth) + (itemWidth / 2) - 8;
        final y = size.height - (normalizedTemp * size.height);

        if (isFirstPoint) {
          path.moveTo(x, y);
          isFirstPoint = false;
        } else if (lastX != null && lastY != null) {
          path.moveTo(lastX, lastY);
          path.lineTo(x, y);
        }

        canvas.drawCircle(
          Offset(x, y),
          4,
          Paint()..color = Colors.white,
        );

        lastX = x;
        lastY = y;
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
