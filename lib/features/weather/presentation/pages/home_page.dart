import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:callduck_weather/features/weather/presentation/widgets/weather_details.dart';
import 'package:callduck_weather/features/weather/presentation/widgets/hourly_forecast.dart';
import 'package:callduck_weather/features/weather/presentation/widgets/daily_forecast.dart';
import 'package:callduck_weather/features/weather/presentation/providers/weather_provider.dart';
import 'package:callduck_weather/app/providers/theme_provider.dart';
import 'package:callduck_weather/app/models/wallpaper_settings.dart';
import 'package:callduck_weather/features/weather/presentation/providers/hitokoto_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  static const double _scrollThreshold = 100.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() {
      _scrollOffset = _scrollController.offset;
    });
  }

  Color _getAdaptiveTextColor(BuildContext context, WallpaperSettings? wallpaperSettings) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    if (wallpaperSettings != null && wallpaperSettings.enabled && wallpaperSettings.imagePath != null) {
      return isDarkMode ? Colors.white : Colors.black;
    }
    
    return Theme.of(context).colorScheme.onSurface;
  }

  @override
  Widget build(BuildContext context) {
    final weatherAsync = ref.watch(currentWeatherProvider);
    final themeSettingsAsync = ref.watch(themeSettingsControllerProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final scrollProgress = (_scrollOffset / _scrollThreshold).clamp(0.0, 1.0);
    final isAppBarVisible = _scrollOffset > _scrollThreshold;

    return themeSettingsAsync.when(
      data: (themeSettings) {
        final wallpaperSettings = themeSettings.wallpaperSettings;
        
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: AnimatedOpacity(
              opacity: isAppBarVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: AppBar(
                backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                elevation: 0,
                title: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getAdaptiveTextColor(context, wallpaperSettings),
                  ),
                  child: const Text('观天象'),
                ),
                centerTitle: false,
                leadingWidth: 0,
                leading: Container(),
                actions: [
                  SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () async {
                      await ref.refresh(currentWeatherProvider.future);
                      await ref.refresh(hourlyForecastProvider.future);
                      await ref.refresh(dailyForecastProvider.future);
                    },
                  ),
                  SizedBox(width: 8),
                ],
              ),
            ),
          ),
          body: Stack(
            children: [
              if (wallpaperSettings.enabled && wallpaperSettings.imagePath != null)
                Positioned.fill(
                  child: _buildWallpaper(wallpaperSettings),
                ),
              weatherAsync.when(
                data: (weather) => NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollUpdateNotification) {
                      _onScroll();
                    }
                    return false;
                  },
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 16,
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: Tween<double>(
                                begin: 60,
                                end: 0,
                              ).transform(scrollProgress),
                            ),
                            AnimatedPadding(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.only(
                                left: Tween<double>(
                                  begin: 0,
                                  end: 56,
                                ).transform(scrollProgress),
                              ),
                              child: Opacity(
                                opacity: 1.0 - scrollProgress,
                                child: Text(
                                  '观天象',
                                  style: TextStyle(
                                    fontSize: Tween<double>(
                                      begin: 32,
                                      end: 0,
                                    ).transform(scrollProgress) + 18,
                                    fontWeight: FontWeight.bold,
                                    color: _getAdaptiveTextColor(context, wallpaperSettings),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Card(
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      weather.cityName,
                                      style: Theme.of(context).textTheme.displaySmall,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${weather.temperature.toStringAsFixed(1)}°C',
                                              style: Theme.of(context).textTheme.displayLarge,
                                            ),
                                            Text(
                                              weather.condition,
                                              style: Theme.of(context).textTheme.bodyLarge,
                                            ),
                                          ],
                                        ),
                                        Icon(
                                          _getWeatherIcon(weather.condition),
                                          size: 64,
                                          color: _getWeatherIconColor(weather.condition),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    WeatherDetails(weather: weather),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '每小时预报',
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: _getAdaptiveTextColor(context, wallpaperSettings),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const HourlyForecast(),
                            const SizedBox(height: 16),
                            Text(
                              '未来几日预报',
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: _getAdaptiveTextColor(context, wallpaperSettings),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const DailyForecast(),
                            const SizedBox(height: 16),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Text(
                                  '天气源 from 高德地图',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                loading: () => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('正在获取天气数据...'),
                    ],
                  ),
                ),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text('加载失败: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.refresh(currentWeatherProvider);
                        },
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                right: 16,
                child: AnimatedOpacity(
                  opacity: isAppBarVisible ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () async {
                        await ref.refresh(currentWeatherProvider.future);
                        await ref.refresh(hourlyForecastProvider.future);
                        await ref.refresh(dailyForecastProvider.future);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('加载主题设置失败: $error'),
        ),
      ),
    );
  }

  IconData _getWeatherIcon(String condition) {
    if (condition.contains('晴')) return Icons.wb_sunny;
    if (condition.contains('多云')) return Icons.cloud;
    if (condition.contains('阴')) return Icons.cloud;
    if (condition.contains('雨')) return Icons.grain;
    if (condition.contains('雪')) return Icons.ac_unit;
    if (condition.contains('雾') || condition.contains('霾')) return Icons.foggy;
    if (condition.contains('雷')) return Icons.flash_on;
    
    return Icons.cloud;
  }

  Color _getWeatherIconColor(String condition) {
    if (condition.contains('晴')) return Colors.orange;
    if (condition.contains('多云')) return Colors.blueGrey;
    if (condition.contains('阴')) return Colors.grey;
    if (condition.contains('雨')) return Colors.blue;
    if (condition.contains('雪')) return Colors.cyan;
    if (condition.contains('雾') || condition.contains('霾')) return Colors.grey;
    if (condition.contains('雷')) return Colors.purple;
    
    return Colors.blue;
  }

  Widget _buildWallpaper(dynamic wallpaperSettings) {
    return Stack(
      children: [
        Positioned.fill(
          child: Transform.translate(
            offset: Offset(
              wallpaperSettings.offsetX,
              wallpaperSettings.offsetY,
            ),
            child: Image.file(
              File(wallpaperSettings.imagePath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        if (wallpaperSettings.blurAmount > 0)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: wallpaperSettings.blurAmount,
                sigmaY: wallpaperSettings.blurAmount,
              ),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        if (wallpaperSettings.overlayOpacity > 0)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(wallpaperSettings.overlayOpacity),
            ),
          ),
      ],
    );
  }
}
