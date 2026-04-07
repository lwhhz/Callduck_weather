import 'dart:async';
import 'package:flutter/material.dart';
import 'package:callduck_weather/features/floating_ball/floating_ball_service.dart';
import 'package:callduck_weather/features/weather/domain/models/weather.dart';

class FloatingBall extends StatefulWidget {
  const FloatingBall({super.key});

  @override
  State<FloatingBall> createState() => _FloatingBallState();
}

class _FloatingBallState extends State<FloatingBall> {
  late FloatingBallService _floatingBallService;
  Weather? _currentWeather;
  bool _isExpanded = false;
  
  // 拖动相关
  Offset _position = const Offset(0, 50); // 初始位置
  bool _isDragging = false;
  
  // 窗口大小
  Size _windowSize = const Size(800, 600); // 默认窗口大小

  @override
  void initState() {
    super.initState();
    _floatingBallService = FloatingBallService();
    _updateWeather();
    // 每15分钟更新一次天气
    _startUpdateTimer();
  }

  void _startUpdateTimer() {
    Timer.periodic(const Duration(minutes: 15), (timer) {
      _updateWeather();
    });
  }

  Future<void> _updateWeather() async {
    await _floatingBallService.updateWeather();
    setState(() {
      _currentWeather = _floatingBallService.currentWeather;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_floatingBallService.isVisible) {
      return const SizedBox.shrink();
    }

    // 获取当前窗口大小
    final mediaQuery = MediaQuery.of(context);
    _windowSize = mediaQuery.size;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey[850] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryTextColor = isDarkMode ? Colors.grey[400] : Colors.grey;

    // 计算悬浮球大小
    final ballWidth = _isExpanded ? 200.0 : 80.0;
    final ballHeight = _isExpanded ? 150.0 : 80.0;

    // 确保悬浮球位置在窗口边界内
    final constrainedPosition = Offset(
      _position.dx.clamp(0.0, _windowSize.width - ballWidth),
      _position.dy.clamp(0.0, _windowSize.height - ballHeight),
    );

    return Positioned(
      left: constrainedPosition.dx,
      top: constrainedPosition.dy,
      child: GestureDetector(
        onPanStart: (_) {
          setState(() {
            _isDragging = true;
          });
        },
        onPanUpdate: (details) {
          setState(() {
            _position = Offset(
              _position.dx + details.delta.dx,
              _position.dy + details.delta.dy,
            );
          });
        },
        onPanEnd: (_) {
          setState(() {
            _isDragging = false;
          });
        },
        onTap: () {
          // 只有在非拖动状态下才触发点击
          if (!_isDragging) {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          }
        },
        child: Container(
          width: ballWidth,
          height: ballHeight,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(_isExpanded ? 16 : 30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: _isExpanded
              ? const EdgeInsets.all(16)
              : const EdgeInsets.all(12),
          child: _isExpanded
              ? _buildExpandedContent(textColor, secondaryTextColor)
              : _buildCompactContent(textColor, secondaryTextColor),
        ),
      ),
    );
  }

  Widget _buildCompactContent(Color textColor, Color? secondaryTextColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _currentWeather != null
              ? '${_currentWeather!.temperature.toStringAsFixed(1)}°C'
              : '--°C',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          '点击查看详情',
          style: TextStyle(
            fontSize: 10,
            color: secondaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedContent(Color textColor, Color? secondaryTextColor) {
    if (_currentWeather == null) {
      return Text(
        '加载天气中...',
        style: TextStyle(color: textColor),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _currentWeather!.cityName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_currentWeather!.temperature.toStringAsFixed(1)}°C',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          _currentWeather!.condition,
          style: TextStyle(
            fontSize: 14,
            color: secondaryTextColor,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildDetailItem('湿度', '${_currentWeather!.humidity}%', textColor, secondaryTextColor),
            const SizedBox(width: 16),
            _buildDetailItem('风速', '${_currentWeather!.windSpeed} m/s', textColor, secondaryTextColor),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildDetailItem('气压', '${_currentWeather!.pressure} hPa', textColor, secondaryTextColor),
            const SizedBox(width: 16),
            _buildDetailItem('降雨', '${_currentWeather!.precipitation}%', textColor, secondaryTextColor),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, Color textColor, Color? secondaryTextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: secondaryTextColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
