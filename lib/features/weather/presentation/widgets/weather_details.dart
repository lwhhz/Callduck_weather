import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:callduck_weather/features/weather/domain/models/weather.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:callduck_weather/app/providers/theme_provider.dart';
import 'package:callduck_weather/features/weather/presentation/providers/hitokoto_provider.dart';

enum WeatherInfoType {
  humidity,
  windSpeed,
  windDirection,
  pressure,
  precipitation,
  feelsLike,
  province,
  reportTime,
  condition,
  temperature,
}

class WeatherInfoConfig {
  final WeatherInfoType type;
  final String label;
  final IconData icon;
  final String Function(Weather) getValue;

  WeatherInfoConfig({
    required this.type,
    required this.label,
    required this.icon,
    required this.getValue,
  });
}

class WeatherDetails extends ConsumerStatefulWidget {
  final Weather weather;

  const WeatherDetails({super.key, required this.weather});

  @override
  ConsumerState<WeatherDetails> createState() => _WeatherDetailsState();
}

class _WeatherDetailsState extends ConsumerState<WeatherDetails> {
  List<WeatherInfoType> _selectedTypes = [
    WeatherInfoType.humidity,
    WeatherInfoType.windSpeed,
    WeatherInfoType.pressure,
    WeatherInfoType.precipitation,
  ];

  final List<WeatherInfoConfig> _availableConfigs = [
    WeatherInfoConfig(
      type: WeatherInfoType.humidity,
      label: '湿度',
      icon: Icons.water_drop,
      getValue: (w) => '${w.humidity}%',
    ),
    WeatherInfoConfig(
      type: WeatherInfoType.windSpeed,
      label: '风速',
      icon: Icons.air,
      getValue: (w) => '${w.windSpeed} m/s',
    ),
    WeatherInfoConfig(
      type: WeatherInfoType.windDirection,
      label: '风向',
      icon: Icons.navigation,
      getValue: (w) => w.windDirection,
    ),
    WeatherInfoConfig(
      type: WeatherInfoType.pressure,
      label: '气压',
      icon: Icons.compress,
      getValue: (w) => '${w.pressure} hPa',
    ),
    WeatherInfoConfig(
      type: WeatherInfoType.precipitation,
      label: '降雨',
      icon: Icons.water,
      getValue: (w) => '${w.precipitation}%',
    ),
    WeatherInfoConfig(
      type: WeatherInfoType.feelsLike,
      label: '体感温度',
      icon: Icons.thermostat,
      getValue: (w) => '${_calculateFeelsLike(w.temperature, w.humidity, w.windSpeed).toStringAsFixed(1)}°',
    ),
    WeatherInfoConfig(
      type: WeatherInfoType.province,
      label: '省份',
      icon: Icons.location_city,
      getValue: (w) => w.provinceName,
    ),
    WeatherInfoConfig(
      type: WeatherInfoType.reportTime,
      label: '发布时间',
      icon: Icons.access_time,
      getValue: (w) => '${w.reportTime.hour.toString().padLeft(2, '0')}:${w.reportTime.minute.toString().padLeft(2, '0')}',
    ),
    WeatherInfoConfig(
      type: WeatherInfoType.condition,
      label: '天气',
      icon: Icons.cloud,
      getValue: (w) => w.condition,
    ),
    WeatherInfoConfig(
      type: WeatherInfoType.temperature,
      label: '温度',
      icon: Icons.thermostat_outlined,
      getValue: (w) => '${w.temperature.toStringAsFixed(1)}°',
    ),
  ];

  static double _calculateFeelsLike(double temp, int humidity, double windSpeed) {
    double feelsLike = temp;
    
    if (temp >= 27 && humidity >= 40) {
      double hi = -8.784695 +
          1.61139411 * temp +
          2.338549 * humidity -
          0.14611605 * temp * humidity -
          0.012308094 * temp * temp -
          0.016424828 * humidity * humidity +
          0.002211732 * temp * temp * humidity +
          0.00072546 * temp * humidity * humidity -
          0.000003582 * temp * temp * humidity * humidity;
      feelsLike = hi;
    } else if (temp <= 10 && windSpeed > 4.8) {
      double ws = windSpeed * 3.6;
      double wc = 13.12 + 0.6215 * temp - 11.37 * math.pow(ws, 0.16) + 0.3965 * temp * math.pow(ws, 0.16);
      feelsLike = wc;
    }
    
    return feelsLike;
  }

  @override
  void initState() {
    super.initState();
    _loadSelectedTypes();
  }

  Future<void> _loadSelectedTypes() async {
    final prefs = await SharedPreferences.getInstance();
    final typesJson = prefs.getString('weatherInfoTypes');
    if (typesJson != null) {
      final List<dynamic> typesList = json.decode(typesJson);
      setState(() {
        _selectedTypes = typesList
            .map((index) => WeatherInfoType.values[index as int])
            .toList();
      });
    }
  }

  Future<void> _saveSelectedTypes() async {
    final prefs = await SharedPreferences.getInstance();
    final typesJson = json.encode(_selectedTypes.map((t) => t.index).toList());
    await prefs.setString('weatherInfoTypes', typesJson);
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('选择天气信息'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _availableConfigs.length,
                  itemBuilder: (context, index) {
                    final config = _availableConfigs[index];
                    final isSelected = _selectedTypes.contains(config.type);
                    
                    return CheckboxListTile(
                      title: Row(
                        children: [
                          Icon(config.icon, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(config.label),
                        ],
                      ),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value == true) {
                            if (_selectedTypes.length < 4) {
                              _selectedTypes.add(config.type);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('最多只能选择4个天气信息')),
                              );
                            }
                          } else {
                            if (_selectedTypes.length > 1) {
                              _selectedTypes.remove(config.type);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('至少需要保留1个天气信息')),
                              );
                            }
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {});
                    _saveSelectedTypes();
                    Navigator.of(context).pop();
                  },
                  child: const Text('确定'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  WeatherInfoConfig _getConfig(WeatherInfoType type) {
    return _availableConfigs.firstWhere((config) => config.type == type);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final themeSettingsAsync = ref.watch(themeSettingsControllerProvider);
    
    return themeSettingsAsync.when(
      data: (themeSettings) {
        final monetEnabled = themeSettings.monetEnabled;
        final cardOpacity = themeSettings.cardOpacity;
        final monetColor = themeSettings.monetColor;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _showEditDialog,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: _getCardColor(context, isDarkMode, monetEnabled, cardOpacity),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit,
                          size: 16,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '修改',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Consumer(builder: (context, ref, child) {
              final hitokotoAsync = ref.watch(hitokotoProvider);
              
              return hitokotoAsync.when(
                data: (hitokoto) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: _getCardColor(context, isDarkMode, monetEnabled, cardOpacity),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '一句',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        hitokoto.content,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      if (hitokoto.from.isNotEmpty) 
                        const SizedBox(height: 12),
                      if (hitokoto.from.isNotEmpty) 
                        Text(
                          '—— ${hitokoto.from}${hitokoto.fromWho.isNotEmpty ? ' · ${hitokoto.fromWho}' : ''}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            color: isDarkMode ? Colors.white54 : Colors.black45,
                          ),
                          textAlign: TextAlign.right,
                        ),
                    ],
                  ),
                ),
                loading: () => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: _getCardColor(context, isDarkMode, monetEnabled, cardOpacity),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: const Center(
                    child: SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                error: (error, stack) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: _getCardColor(context, isDarkMode, monetEnabled, cardOpacity),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '一句',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '每日一句加载失败',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '—— 母鸡卡',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: isDarkMode ? Colors.white54 : Colors.black45,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: _selectedTypes.map((type) {
                final config = _getConfig(type);
                return _buildDetailItem(
                  context,
                  config.icon,
                  config.label,
                  config.getValue(widget.weather),
                  isDarkMode,
                  monetEnabled,
                  cardOpacity,
                );
              }).toList(),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('加载设置失败')),
    );
  }

  Color _getCardColor(BuildContext context, bool isDarkMode, bool monetEnabled, double opacity) {
    if (monetEnabled) {
      final primaryContainer = Theme.of(context).colorScheme.primaryContainer;
      return primaryContainer.withOpacity(opacity);
    }
    final surfaceVariant = Theme.of(context).colorScheme.surfaceVariant;
    return surfaceVariant.withOpacity(opacity);
  }

  Widget _buildDetailItem(BuildContext context, IconData icon, String label, String value, bool isDarkMode, bool monetEnabled, double cardOpacity) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: _getCardColor(context, isDarkMode, monetEnabled, cardOpacity),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.blue, size: 36),
          const SizedBox(height: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 20),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
