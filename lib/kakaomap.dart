import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kakaomap_webview/kakaomap_webview.dart';
import 'package:geocoding/geocoding.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'weather_page.dart';
import 'weatherapi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String kakaoMapKey = dotenv.get('kakao_API_KEY');

class KakaoMap extends StatefulWidget {
  final Map<String, dynamic>? liveData;
  final Position? currentPosition;

  const KakaoMap(
      {super.key, required this.liveData, required this.currentPosition});

  @override
  State<KakaoMap> createState() => _KakaoMapState();
}

class _KakaoMapState extends State<KakaoMap> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  double? _latitude;
  double? _longitude;
  Map<String, dynamic>? _liveData;
  late WebViewController _mapController;
  Position? searchPosition;

  @override
  void initState() {
    super.initState();
    _latitude = widget.currentPosition?.latitude;
    _longitude = widget.currentPosition?.longitude;
    _liveData = widget.liveData;
  }

  Future<void> _searchLocation() async {
    try {
      List<Location> locations =
          await locationFromAddress(_searchText, localeIdentifier: 'ko_KR');
      if (locations.isNotEmpty) {
        Location location = locations.first;
        setState(() {
          searchPosition = Position(
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

          _latitude = location.latitude;
          _longitude = location.longitude;
        });
        _updateKakaoMapLocation();
        ApiService.fetchData(
            searchPosition!, 'live', (data) => _liveData = data, setState);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('주소를 찾을 수 없습니다')),
      );
    }
  }

  void _updateKakaoMapLocation() {
    _mapController.runJavascript('marker.setMap(null);');
    if (_latitude != null && _longitude != null) {
      _mapController.runJavascript('''
        map.setCenter(new kakao.maps.LatLng($_latitude, $_longitude));
        addMarker(new kakao.maps.LatLng($_latitude, $_longitude));
        function addMarker(position) {
          let marker = new kakao.maps.Marker({position: position});
          marker.setMap(map);
        }
      ''');
      setState(() {});
    }
  }

  void _moveToCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
      ApiService.fetchData(
          position, 'live', (data) => _liveData = data, setState);
      _updateKakaoMapLocation();
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          KakaoMapView(
            width: size.width,
            height: size.height,
            kakaoMapKey: kakaoMapKey,
            lat: widget.currentPosition?.latitude ?? 0.0,
            lng: widget.currentPosition?.longitude ?? 0.0,
            mapController: (controller) {
              _mapController = controller;
            },
          ),
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: _buildSearchBar(),
          ),
          Positioned(
            bottom: 30,
            left: 45,
            right: 45,
            child: _buildLocationInfo(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '주소 검색',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search),
                ),
                onSubmitted: (value) {
                  setState(() {
                    _searchText = value;
                  });
                  _searchLocation();
                  _searchController.clear();
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                shape: const CircleBorder(),
              ),
              onPressed: () {
                setState(() {
                  debugPrint("Search Text: ${_searchController.text}");
                  _searchText = _searchController.text;
                });
                _searchLocation();
                _searchController.clear();
              },
            ),
            IconButton(
              icon: const Icon(Icons.my_location, color: Colors.black),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                shape: const CircleBorder(),
              ),
              onPressed: _moveToCurrentLocation,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_liveData?['region'][2] ?? '위치 확인 중...'}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_liveData?['region'][0] ?? ''}, ${_liveData?['region'][1] ?? ''}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${_liveData?['data']['temp']}°',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: _navigateToWeatherHomePage,
                child: const Text('상세정보'),
              ),
              TextButton(
                onPressed: _addLocationToCache,
                child: const Text('추가'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToWeatherHomePage() async {
    if (_liveData != null &&
        _liveData!.containsKey('region') &&
        _liveData!['region'] is List) {
      try {
        final String address = (_liveData!['region'] as List).join(' ');
        List<Location> locations =
            await locationFromAddress(address, localeIdentifier: 'ko_KR');
        if (locations.isNotEmpty && mounted) {
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('주소를 찾을 수 없습니다')),
          );
        }
      }
    }
  }

  Future<void> _addLocationToCache() async {
    final prefs = await SharedPreferences.getInstance();
    String cacheKey = _liveData?['region'][2].toString() ?? 'defaultRegionKey';
    await prefs.setString(cacheKey, json.encode(_liveData));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('지역이 추가되었습니다'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }
}
