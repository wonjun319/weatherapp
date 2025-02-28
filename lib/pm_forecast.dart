import 'package:flutter/material.dart';

class PmForecast extends StatelessWidget {
  final Map<String, dynamic>? liveData;

  const PmForecast({super.key, required this.liveData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _buildPmRows(),
      ),
    );
  }

  List<Widget> _buildPmRows() {
    final Map<String, dynamic> pmData = liveData!['pm'];

    final List<Map<String, dynamic>> processedData = [
      {
        'title': '미세먼지',
        'value': pmData['pm10Value'],
        'grade': pmData['pm10Grade'],
        'unit': 'μg/m³'
      },
      {
        'title': '초미세먼지',
        'value': pmData['pm25Value'],
        'grade': pmData['pm25Grade'],
        'unit': 'μg/m³'
      }
    ];

    return processedData.map((data) {
      final value = int.tryParse(data['value'] ?? '0') ?? 0;
      final maxValue = data['title'] == '미세먼지' ? 150 : 75;
      final progress = (value / maxValue).clamp(0.0, 1.0); // 0.0 ~ 1.0 사이값으로 제한

      return Column(
        children: [
          Text(
            data['title'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            // 등급 텍스트와 함께 실제 수치 표시
            '${_getGradeText(data['grade'])} (${data['value']}${data['unit']})',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 120,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                Container(
                  width: 120 * progress, // 퍼센트 기반으로 너비 설정
                  decoration: BoxDecoration(
                    color: _getGradeColor(data['grade']),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }).toList();
  }

  // 등급에 따른 색상 설정 - 클래스 멤버 메소드로 이동
  Color _getGradeColor(String? grade) {
    switch (grade) {
      case '1':
        return Colors.blue;
      case '2':
        return Colors.green;
      case '3':
        return Colors.orange;
      case '4':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // 등급에 따른 텍스트 설정 - 클래스 멤버 메소드로 이동
  String _getGradeText(String? grade) {
    switch (grade) {
      case '1':
        return '좋음';
      case '2':
        return '보통';
      case '3':
        return '나쁨';
      case '4':
        return '매우나쁨';
      default:
        return '통신장애';
    }
  }
}
