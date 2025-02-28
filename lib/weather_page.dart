import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'currenttime.dart';
import 'drawer.dart';
import 'erroescrean.dart';
import 'hourly_forecast.dart';
import 'theme.dart';
import 'weekly_forecast.dart';
import 'temperature_comparison.dart';
import 'pm_forecast.dart';
import 'weatherapi.dart';

class WeatherHomePage extends StatefulWidget {
  final Position? position;
  const WeatherHomePage({this.position, super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Position? _currentPosition;
  Map<String, dynamic>? _liveData;
  Map<String, dynamic>? _dailyData;
  Map<String, dynamic>? _weeklyData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    widget.position != null
        ? _initializeWithPosition(widget.position!)
        : _getCurrentLocation();
  }

  Future<void> _initializeWithPosition(Position position) async {
    setState(() => _currentPosition = position);
    await _fetchAllData(position);
    setState(() => _isLoading = false);
  }

  Future<void> _getCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        setState(() => _isLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoading = false);
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() => _currentPosition = position);

      await _fetchAllData(position);
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error getting location: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchAllData(Position position) async {
    await Future.wait([
      ApiService.fetchData(
          position, 'live', (data) => _liveData = data, setState),
      ApiService.fetchData(
          position, 'daily', (data) => _dailyData = data, setState),
      ApiService.fetchData(
          position, 'weekly', (data) => _weeklyData = data, setState)
    ]);
  }

  Future<void> _handleRefresh() async {
    _currentPosition != null
        ? await _fetchAllData(_currentPosition!)
        : await _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoadingScreen();
    if (_error != null)
      return ErrorScreen(message: _error!, onRetry: _getCurrentLocation);

    if (_liveData == null || _dailyData == null || _weeklyData == null) {
      return ErrorScreen(
        title: '데이터 로딩 실패',
        message: '날씨 정보를 불러오는데 실패했습니다.',
        onRetry: () => _initializeWithPosition(_currentPosition!),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      backgroundColor: AppTheme.getBackgroundColor(_liveData!),
      drawer: WeatherDrawer(
        liveData: _liveData,
        currentPosition: _currentPosition,
        backgroundColor: AppTheme.getBackgroundColor(_liveData!),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CurrentWeather(liveData: _liveData),
                  const SizedBox(height: 10),
                  HourlyForecast(dailyData: _dailyData),
                  const SizedBox(height: 16),
                  TemperatureComparison(liveData: _liveData),
                  const SizedBox(height: 16),
                  WeeklyForecast(weeklyData: _weeklyData),
                  const SizedBox(height: 16),
                  PmForecast(liveData: _liveData)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              '날씨 정보를 불러오는 중...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          Expanded(
            child: Text(
              _currentPosition != null
                  ? '${_liveData?['region'][2] ?? '위치 확인 중...'}'
                  : '위치 정보 가져오는 중...',
              style: const TextStyle(color: Colors.white, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
