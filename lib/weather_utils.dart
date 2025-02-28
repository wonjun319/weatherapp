import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

class WeatherUtils {
  static IconData getAmWeatherIcon(String? skyStatus) {
    switch (skyStatus) {
      case '맑음':
        return UniconsLine.sun;
      case '구름많음':
        return UniconsLine.cloud_sun;
      case '구름많고 비':
        return UniconsLine.cloud_sun_rain;
      case '구름많고 눈':
        return UniconsLine.cloud_sun_meatball;
      case '구름많고 비/눈':
        return UniconsLine.cloud_sun_hail;
      case '구름많고 소나기':
        return UniconsLine.cloud_drizzle;
      case '흐림':
        return UniconsLine.clouds;
      case '흐리고 비':
        return UniconsLine.cloud_rain;
      case '흐리고 눈':
        return UniconsLine.cloud_meatball;
      case '흐리고 비/눈':
        return UniconsLine.cloud_hail;
      case '흐리고 소나기':
        return UniconsLine.cloud_drizzle;
      case 'sunrise':
        return FeatherIcons.sunrise;
      default:
        return UniconsLine.question;
    }
  }

  static IconData getPmWeatherIcon(String? skyStatus) {
    switch (skyStatus) {
      case '맑음':
        return UniconsLine.moon;
      case '구름많음':
        return UniconsLine.cloud_moon;
      case '구름많고 비':
        return UniconsLine.cloud_moon_rain;
      case '구름많고 눈':
        return UniconsLine.cloud_moon_meatball;
      case '구름많고 비/눈':
        return UniconsLine.cloud_moon_hail;
      case '구름많고 소나기':
        return UniconsLine.cloud_drizzle;
      case '흐림':
        return UniconsLine.clouds;
      case '흐리고 비':
        return UniconsLine.cloud_rain;
      case '흐리고 눈':
        return UniconsLine.cloud_meatball;
      case '흐리고 비/눈':
        return UniconsLine.cloud_hail;
      case '흐리고 소나기':
        return UniconsLine.cloud_drizzle;
      case 'sunset':
        return FeatherIcons.sunset;
      default:
        return UniconsLine.question;
    }
  }

  static IconData getWatherIcon(num? rain_prob) {
    if (rain_prob == null) {
      return Icons.format_color_reset_outlined; // Default case for null
    }

    switch (rain_prob) {
      case <= 29:
        return Icons.water_drop_outlined;
      case <= 59:
        return Icons.opacity;
      case <= 100:
        return Icons.water_drop;
      default:
        return Icons
            .format_color_reset_outlined; // Default case for invalid values
    }
  }
}
