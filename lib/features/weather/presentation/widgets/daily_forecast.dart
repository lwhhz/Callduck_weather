import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:callduck_weather/features/weather/presentation/providers/weather_provider.dart';
import 'package:callduck_weather/app/providers/theme_provider.dart';

class DailyForecast extends ConsumerWidget {
  const DailyForecast({super.key});

  Color _getCardColor(BuildContext context, bool isDarkMode, bool monetEnabled, double opacity) {
    if (monetEnabled) {
      final primaryContainer = Theme.of(context).colorScheme.primaryContainer;
      return primaryContainer.withOpacity(opacity);
    }
    final surfaceVariant = Theme.of(context).colorScheme.surfaceVariant;
    return surfaceVariant.withOpacity(opacity);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyAsync = ref.watch(dailyForecastProvider);
    final themeSettingsAsync = ref.watch(themeSettingsControllerProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return themeSettingsAsync.when(
      data: (themeSettings) {
        final monetEnabled = themeSettings.monetEnabled;
        final cardOpacity = themeSettings.cardOpacity;
        final monetColor = themeSettings.monetColor;

        return dailyAsync.when(
          data: (dailyForecasts) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: _getCardColor(context, isDarkMode, monetEnabled, cardOpacity),
            ),
            child: Column(
              children: [
                // 数据名称栏
                _buildHeaderRow(context),
                // 每日数据
                ...dailyForecasts.asMap().entries.map((entry) {
                  int index = entry.key;
                  var forecast = entry.value;
                  return Column(
                    children: [
                      // 虚线分隔（除了第一行）
                      if (index > 0)
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey,
                          indent: 16,
                          endIndent: 16,
                        ),
                      _buildDailyItem(context, forecast, isDarkMode),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('加载失败: $error')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('加载设置失败')),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '日期',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            '天气',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Row(
            children: [
              Text(
                '低温',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 16),
              Text(
                '高温',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          Text(
            '降雨',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyItem(BuildContext context, dynamic forecast, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _formatDate(forecast.date),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Icon(
            _getWeatherIcon(forecast.condition),
            size: 24,
            color: _getWeatherIconColor(forecast.condition),
          ),
          Row(
            children: [
              Text(
                '${forecast.minTemperature.toStringAsFixed(1)}°',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.right,
              ),
              const SizedBox(width: 16),
              Text(
                '${forecast.maxTemperature.toStringAsFixed(1)}°',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.right,
              ),
            ],
          ),
          Text(
            '${forecast.precipitation}%',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return '今天';
    } else if (date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day) {
      return '明天';
    } else {
      return '${date.month}/${date.day}';
    }
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
}
