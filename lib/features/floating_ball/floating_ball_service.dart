import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:callduck_weather/features/weather/data/services/weather_api_service.dart';
import 'package:callduck_weather/features/weather/domain/models/weather.dart';

class FloatingBallService {
  static final FloatingBallService _instance = FloatingBallService._internal();
  late WeatherApiService _weatherApiService;
  bool _isVisible = false;
  Weather? _currentWeather;
  Timer? _updateTimer;

  factory FloatingBallService() {
    return _instance;
  }

  FloatingBallService._internal() {
    _weatherApiService = WeatherApiService();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('floatingBallEnabled') ?? true;
    if (enabled) {
      await showFloatingBall();
    }
  }

  Future<void> showFloatingBall() async {
    if (_isVisible) return;

    _isVisible = true;
    _startUpdateTimer();
    
    // 这里需要实现悬浮球窗口的创建和显示
    // 由于Flutter的限制，我们需要在主应用中处理悬浮球的显示
  }

  Future<void> hideFloatingBall() async {
    if (!_isVisible) return;

    _isVisible = false;
    _stopUpdateTimer();
    
    // 这里需要实现悬浮球窗口的隐藏
  }

  void _startUpdateTimer() {
    _stopUpdateTimer();
    _updateTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
      _updateWeather();
    });
    _updateWeather();
  }

  void _stopUpdateTimer() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  Future<void> _updateWeather() async {
    try {
      _currentWeather = await _weatherApiService.getCurrentWeather(39.9042, 116.4074);
    } catch (e) {
      print('更新天气失败: $e');
    }
  }

  Future<void> updateWeather() async {
    await _updateWeather();
  }

  Weather? get currentWeather => _currentWeather;
  bool get isVisible => _isVisible;
}
