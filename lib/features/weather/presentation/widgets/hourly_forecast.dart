import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:callduck_weather/features/weather/presentation/providers/weather_provider.dart';
import 'package:callduck_weather/app/providers/theme_provider.dart';

class HourlyForecast extends ConsumerWidget {
  const HourlyForecast({super.key});

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
    final hourlyAsync = ref.watch(hourlyForecastProvider);
    final themeSettingsAsync = ref.watch(themeSettingsControllerProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return themeSettingsAsync.when(
      data: (themeSettings) {
        final monetEnabled = themeSettings.monetEnabled;
        final cardOpacity = themeSettings.cardOpacity;
        final monetColor = themeSettings.monetColor;

        return hourlyAsync.when(
          data: (hourlyForecasts) => Container(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: hourlyForecasts.length,
              itemBuilder: (context, index) {
                final forecast = hourlyForecasts[index];
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: _getCardColor(context, isDarkMode, monetEnabled, cardOpacity),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${forecast.time.hour}:00',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                      ),
                      const SizedBox(height: 6),
                      Icon(
                        _getWeatherIcon(forecast.condition),
                        size: 20,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${forecast.temperature.toStringAsFixed(1)}°',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${forecast.precipitation}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
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

  IconData _getWeatherIcon(String condition) {
    if (condition.contains('晴')) return Icons.sunny;
    if (condition.contains('多云')) return Icons.cloud;
    if (condition.contains('阴')) return Icons.cloud;
    if (condition.contains('雨')) return Icons.water_drop;
    if (condition.contains('雪')) return Icons.ac_unit;
    if (condition.contains('雾') || condition.contains('霾')) return Icons.foggy;
    if (condition.contains('雷')) return Icons.thunderstorm;
    
    return Icons.cloud;
  }
}
