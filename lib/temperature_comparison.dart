import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

class TemperatureComparison extends StatefulWidget {
  final Map<String, dynamic>? liveData;

  const TemperatureComparison({super.key, required this.liveData});

  @override
  State<TemperatureComparison> createState() => _TemperatureComparisonState();
}

class _TemperatureComparisonState extends State<TemperatureComparison> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data = widget.liveData?['data'];
    final double temp = data['temp'].toDouble();
    final double wind = (data['wind'] as num).toDouble();
    final double windChillTemp =
        TemperatureUtils.calculateWindChill(temp, wind);
    final double tempGap =
        double.parse((temp - windChillTemp).toStringAsFixed(1));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 80, // 카드 내용물 높이 조절
            child: PageView(
              controller: _pageController,
              children: [
                // 첫 번째 페이지 (체감온도)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.thermostat,
                              color: Colors.white,
                              size: 18,
                            ),
                            Text(
                              '체감온도',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          '체감온도는 실제 기온보다 ${tempGap.abs()}° ${tempGap > 0 ? '낮아요' : '높아요'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '$windChillTemp°',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24, // 크기를 더 키움
                            fontWeight: FontWeight.w700, // 볼드 처리
                            letterSpacing: -1, // 글자 간격을 좁혀서 더 강조
                          ),
                        ),
                        const SizedBox(width: 15)
                      ],
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              FeatherIcons.sun,
                              color: Colors.white,
                              size: 18,
                            ),
                            Text(
                              _isAfterSunset(widget.liveData?['sunset'])
                                  ? '일출시각'
                                  : '일몰시각',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _isAfterSunset(widget.liveData?['sunset'])
                              ? '오전 ${_formatTime(widget.liveData?['sunset']['sunrise'])}에 해가 떠요'
                              : '오후 ${_formatTime(widget.liveData?['sunset']['sunset'])}에 해가 져요',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          _isAfterSunset(widget.liveData?['sunset'])
                              ? FeatherIcons.sunrise
                              : FeatherIcons.sunset,
                          color: Colors.white,
                          size: 50,
                        ),
                        const SizedBox(width: 15),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          // 페이지 인디케이터
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              2, // 페이지 수
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? Colors.white
                      : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

bool _isAfterSunset(Map<String, dynamic> sunsetData) {
  final now = DateTime.now();
  final currentTime = now.hour * 100 + now.minute;
  final sunset = int.parse(sunsetData['sunset']);
  return currentTime >= sunset ||
      currentTime < int.parse(sunsetData['sunrise']);
}

String _formatTime(String time) {
  final hour = int.parse(time.substring(0, 2));
  final minute = time.substring(2);
  return '$hour:$minute';
}

class TemperatureUtils {
  static double calculateWindChill(double temp, double wind) {
    num windKmh = wind * 3.6;
    num windPow = math.pow(windKmh, 0.16);
    double windChill =
        13.12 + 0.6215 * temp - 11.37 * windPow + 0.3965 * temp * windPow;
    return double.parse(windChill.toStringAsFixed(1));
  }
}
