import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'kakaomap.dart';
import 'weather_page.dart';

class WeatherDrawer extends StatefulWidget {
  final Map<String, dynamic>? liveData;
  final Position? currentPosition;
  final Color backgroundColor;

  const WeatherDrawer({
    super.key,
    required this.liveData,
    this.currentPosition,
    required this.backgroundColor,
  });

  @override
  State<WeatherDrawer> createState() => _WeatherDrawerState();
}

class _WeatherDrawerState extends State<WeatherDrawer> {
  List<String> _locationKeys = [];
  Map<String, List<String>> _locationData = {};
  bool _isManageMode = false;

  @override
  void initState() {
    super.initState();
    _loadLocationKeys();
  }

  Future<void> _loadLocationKeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().toList();

      setState(() {
        _locationKeys = keys;
      });
    } catch (e) {
      debugPrint('Failed to load cached location data: $e');
    }
  }

  Future<void> _deleteLocation(String location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(location);

      setState(() {
        _locationKeys.remove(location);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting location: $e')),
        );
      }
    }
  }

  Future<void> _navigateToLocation(String locationText) async {
    try {
      List<Location> locations =
          await locationFromAddress(locationText, localeIdentifier: 'ko_KR');

      if (locations.isNotEmpty) {
        Location location = locations.first;
        Position searchPosition = Position(
          latitude: location.latitude,
          longitude: location.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          headingAccuracy: 0,
        );

        Get.offAll(() => WeatherHomePage(position: searchPosition));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to find address: $e')),
      );
    }
  }

  Widget _buildLocationTile(String location) {
    final regionData = _locationData[location];
    final locationText = regionData?.join(' ') ?? location;

    return _isManageMode
        ? Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => _navigateToLocation(locationText),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.centerLeft,
                  ),
                  child: Text(
                    location,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => _deleteLocation(location),
              ),
            ],
          )
        : TextButton(
            onPressed: () => _navigateToLocation(locationText),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.centerLeft,
            ),
            child: Text(
              location,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: widget.backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.white),
                        onPressed: () {
                          Get.back();
                          Get.to(
                            () => KakaoMap(
                              liveData: widget.liveData,
                              currentPosition: widget.currentPosition,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  ..._locationKeys
                      .map((location) => _buildLocationTile(location)),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isManageMode = !_isManageMode;
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      backgroundColor: Colors.white.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isManageMode ? '완료' : '지역 관리',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
