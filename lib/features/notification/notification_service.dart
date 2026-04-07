import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:callduck_weather/features/weather/data/services/weather_api_service.dart';
import 'package:callduck_weather/features/weather/domain/models/weather.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  late WeatherApiService _weatherApiService;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal() {
    _weatherApiService = WeatherApiService();
    _initializeNotifications();
  }

  void _initializeNotifications() {
    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'weather_channel',
          channelName: '天气通知',
          channelDescription: '每日天气更新通知',
          importance: NotificationImportance.High,
          defaultColor: Color(0xFF4285F4),
          ledColor: Colors.white,
        ),
      ],
    );
  }

  Future<void> scheduleWeatherNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notificationsEnabled') ?? true;
    final timeString = prefs.getString('notificationTime') ?? '08:00';

    if (!enabled) return;

    // 解析时间
    final timeParts = timeString.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    // 取消之前的通知
    await AwesomeNotifications().cancelAllSchedules();

    // 每天在指定时间发送通知
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'weather_channel',
        title: '每日天气',
        body: '获取天气信息...',
        notificationLayout: NotificationLayout.Default,
        color: Color(0xFF4285F4),
      ),
      schedule: NotificationCalendar(
        hour: hour,
        minute: minute,
        second: 0,
        repeats: true,
      ),
    );
  }

  Future<void> sendWeatherNotification() async {
    try {
      // 获取当前天气
      final weather = await _weatherApiService.getCurrentWeather('110000');

      // 发送通知
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 1,
          channelKey: 'weather_channel',
          title: '${weather.cityName} 天气',
          body: '${weather.temperature.toStringAsFixed(1)}°C, ${weather.condition}',
          notificationLayout: NotificationLayout.Default,
          color: Color(0xFF4285F4),
          bigPicture: 'asset://assets/images/weather_${_getWeatherIconName(weather.condition)}.png',
          largeIcon: 'asset://assets/icons/weather_icon.png',
        ),
      );
    } catch (e) {
      print('发送通知失败: $e');
    }
  }

  String _getWeatherIconName(String condition) {
    switch (condition) {
      case '晴天':
        return 'sunny';
      case '多云':
        return 'cloudy';
      case '雨天':
        return 'rainy';
      case '雪天':
        return 'snowy';
      default:
        return 'cloudy';
    }
  }

  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }
}
