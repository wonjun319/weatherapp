import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class ApiService {
  static const int retryCount = 5;
  static const Duration retryDelay = Duration(seconds: 1);

  static Future<void> fetchData(
    Position position,
    String rate,
    Function(dynamic) updateState,
    void Function(void Function()) setState,
  ) async {
    final url = Uri.parse(
      'http://10.0.2.2:8000/api/location/$rate/${position.longitude}/${position.latitude}',
    );

    for (int i = 0; i < retryCount; i++) {
      try {
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final decodedResponse = jsonDecode(response.body);

          if (_validateRate(decodedResponse, rate)) {
            setState(() => updateState(decodedResponse));
            return;
          } else {
            throw FormatException(
                'Response rate does not match requested rate: $rate');
          }
        } else {
          _handleError(rate, response.statusCode, i);
        }
      } catch (e) {
        _handleException(rate, e, i);
      }
    }
  }

  static bool _validateRate(Map<String, dynamic> response, String rate) {
    try {
      if (rate == 'live') {
        return response['data']['rate'] == rate;
      } else {
        return response['data'][0]['rate'] == rate;
      }
    } catch (e) {
      debugPrint('Rate validation error: $e');
      return false;
    }
  }

  static void _handleError(String rate, int statusCode, int attempt) {
    debugPrint('$rate API 오류: $statusCode');
    if (attempt < retryCount - 1) {
      debugPrint('$rate API 재시도 ${attempt + 1}/$retryCount');
    }
  }

  static void _handleException(String rate, dynamic exception, int attempt) {
    debugPrint('$rate API 호출 오류: $exception');
    if (attempt < retryCount - 1) {
      Future.delayed(retryDelay);
    }
  }
}
