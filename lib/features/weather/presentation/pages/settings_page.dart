import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:callduck_weather/features/notification/notification_service.dart';
import 'package:callduck_weather/app/providers/theme_provider.dart';
import 'package:callduck_weather/app/themes/theme.dart';
import 'package:callduck_weather/app/models/wallpaper_settings.dart';
import 'package:file_picker/file_picker.dart';
import 'package:callduck_weather/features/weather/presentation/pages/about_page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _notificationsEnabled = true;
  String _notificationTime = '08:00';
  bool _monetEnabled = false;
  ThemePreset? _preset;
  Color? _customColor;
  bool _wallpaperEnabled = false;
  String? _wallpaperPath;
  double _wallpaperOffsetX = 0.0;
  double _wallpaperOffsetY = 0.0;
  double _wallpaperBlur = 0.0;
  double _wallpaperOverlayOpacity = 0.3;
  double _cardOpacity = 0.8;
  String _weatherApiUrl = '';
  String _weatherApiKey = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _notificationTime = prefs.getString('notificationTime') ?? '08:00';
      _monetEnabled = prefs.getBool('monetEnabled') ?? false;
      
      final presetIndex = prefs.getInt('themePreset');
      if (presetIndex != null) {
        _preset = ThemePreset.values[presetIndex];
      }
      
      final customColorValue = prefs.getInt('customColor');
      if (customColorValue != null) {
        _customColor = Color(customColorValue);
      }

      _wallpaperEnabled = prefs.getBool('wallpaperEnabled') ?? false;
      _wallpaperPath = prefs.getString('wallpaperPath');
      _wallpaperOffsetX = prefs.getDouble('wallpaperOffsetX') ?? 0.0;
      _wallpaperOffsetY = prefs.getDouble('wallpaperOffsetY') ?? 0.0;
      _wallpaperBlur = prefs.getDouble('wallpaperBlur') ?? 0.0;
      _wallpaperOverlayOpacity = prefs.getDouble('wallpaperOverlayOpacity') ?? 0.3;
      _cardOpacity = prefs.getDouble('cardOpacity') ?? 0.8;
      _weatherApiUrl = prefs.getString('weatherApiUrl') ?? '';
      _weatherApiKey = prefs.getString('weatherApiKey') ?? '';
    });
  }

  Future<void> _saveNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setString('notificationTime', _notificationTime);
    await NotificationService().scheduleWeatherNotification();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = ref.read(themeSettingsControllerProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Text(
                '设置',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildWeatherApiCard(),
              const SizedBox(height: 16),
              _buildNotificationCard(),
              const SizedBox(height: 16),
              _buildThemeCard(themeController),
              const SizedBox(height: 16),
              _buildWallpaperCard(themeController),
              const SizedBox(height: 16),
              _buildAboutCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherApiCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('天气源设置', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 16),
            _buildListTile('API URL', () => _showWeatherApiUrlDialog()),
            const SizedBox(height: 8),
            _buildListTile('API Key', () => _showWeatherApiKeyDialog()),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('通知设置', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 16),
            _buildSwitchTile('启用天气通知', _notificationsEnabled, (value) {
              setState(() => _notificationsEnabled = value);
              _saveNotificationSettings();
            }),
            if (_notificationsEnabled)
              ListTile(
                title: const Text('通知时间'),
                subtitle: Text(_notificationTime),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showTimePicker,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(ThemeSettingsController controller) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('主题设置', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 16),
            _buildSwitchTile('启用莫奈取色', _monetEnabled, (value) async {
              setState(() => _monetEnabled = value);
              await controller.updateMonetEnabled(value);
            }, subtitle: '根据壁纸颜色自动调整应用配色'),
            const SizedBox(height: 16),
            _buildCardOpacitySlider(controller),
            if (!_monetEnabled) ...[
              const SizedBox(height: 16),
              Text('主题预设', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 12),
              _buildThemePresets(controller),
              const SizedBox(height: 16),
              Text('自定义颜色', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 12),
              _buildCustomColorPicker(controller),
            ],
          ],
        ),
      ),
    );
  }



  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged, {String? subtitle}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceVariant,
      ),
      child: SwitchListTile(
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        value: value,
        onChanged: onChanged,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildListTile(String title, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceVariant,
      ),
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemePresets(ThemeSettingsController controller) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: ThemePreset.values.map((preset) {
        final color = presetColors[preset]!;
        final isSelected = _preset == preset;
        
        return InkWell(
          onTap: () async {
            setState(() {
              _preset = preset;
              _customColor = null;
            });
            await controller.updatePreset(preset);
          },
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: isSelected ? Border.all(width: 3, color: Colors.white) : null,
              boxShadow: isSelected ? [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ] : null,
            ),
            child: isSelected
                ? const Center(child: Icon(Icons.check, color: Colors.white, size: 24))
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCardOpacitySlider(ThemeSettingsController controller) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceVariant,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('卡片透明度', style: Theme.of(context).textTheme.bodyLarge),
              Text('${(_cardOpacity * 100).toStringAsFixed(0)}%', 
                style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: _cardOpacity,
            min: 0.0,
            max: 1.0,
            divisions: 20,
            onChanged: (value) async {
              setState(() {
                _cardOpacity = value;
              });
              await controller.updateCardOpacity(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCustomColorPicker(ThemeSettingsController controller) {
    final customColor = _customColor ?? Colors.blue;
    final isSelected = _customColor != null;

    return Row(
      children: [
        InkWell(
          onTap: () => _showColorPicker(context, controller),
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: customColor,
              borderRadius: BorderRadius.circular(12),
              border: isSelected ? Border.all(width: 3, color: Colors.white) : null,
              boxShadow: isSelected ? [
                BoxShadow(
                  color: customColor.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ] : null,
            ),
            child: isSelected
                ? const Center(child: Icon(Icons.check, color: Colors.white, size: 24))
                : const Center(child: Icon(Icons.color_lens, color: Colors.white, size: 24)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            '选择自定义主题色',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Future<void> _showColorPicker(BuildContext context, ThemeSettingsController controller) async {
    final Color? pickedColor = await showDialog<Color>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('选择主题色'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (i) {
              return Row(
                children: List.generate(5, (j) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(
                        Colors.primaries[(i * 5 + j) % Colors.primaries.length],
                      ),
                      child: Container(
                        height: 50,
                        color: Colors.primaries[(i * 5 + j) % Colors.primaries.length],
                      ),
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
          ],
        );
      },
    );

    if (pickedColor != null) {
      setState(() {
        _customColor = pickedColor;
        _preset = null;
      });
      await controller.updateCustomColor(pickedColor);
    }
  }

  Future<void> _showTimePicker() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        DateTime.parse('2020-01-01 $_notificationTime:00'),
      ),
    );
    
    if (pickedTime != null) {
      setState(() {
        _notificationTime = pickedTime.format(context);
        _saveNotificationSettings();
      });
    }
  }

  Widget _buildWallpaperCard(ThemeSettingsController controller) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('壁纸设置', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 16),
            _buildSwitchTile('启用壁纸', _wallpaperEnabled, (value) async {
              setState(() => _wallpaperEnabled = value);
              await controller.updateWallpaperEnabled(value);
            }, subtitle: '使用自定义图片作为应用背景'),
            if (_wallpaperEnabled) ...[
              const SizedBox(height: 16),
              _buildWallpaperSelector(controller),
              const SizedBox(height: 16),
              _buildWallpaperPosition(controller),
              const SizedBox(height: 16),
              _buildWallpaperBlur(controller),
              const SizedBox(height: 16),
              _buildWallpaperOverlay(controller),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWallpaperSelector(ThemeSettingsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('选择壁纸', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 12),
        InkWell(
          onTap: _wallpaperPath == null ? () => _selectWallpaper(controller) : null,
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surfaceVariant,
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: _wallpaperPath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.file(
                            File(_wallpaperPath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(child: Icon(Icons.broken_image));
                            },
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: InkWell(
                            onTap: () => _removeWallpaper(controller),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.close, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate, size: 48),
                        SizedBox(height: 8),
                        Text('点击选择壁纸'),
                      ],
                    ),
                  ),
          ),
        ),
        if (_wallpaperPath == null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: ElevatedButton.icon(
              onPressed: () => _selectWallpaper(controller),
              icon: const Icon(Icons.folder_open),
              label: const Text('从文件管理器选择'),
            ),
          ),
      ],
    );
  }

  Widget _buildWallpaperPosition(ThemeSettingsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('壁纸位置', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('水平偏移: ${_wallpaperOffsetX.toStringAsFixed(1)}'),
                  Slider(
                    value: _wallpaperOffsetX,
                    min: -100,
                    max: 100,
                    divisions: 200,
                    onChanged: (value) async {
                      setState(() => _wallpaperOffsetX = value);
                      await controller.updateWallpaperOffset(_wallpaperOffsetX, _wallpaperOffsetY);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('垂直偏移: ${_wallpaperOffsetY.toStringAsFixed(1)}'),
                  Slider(
                    value: _wallpaperOffsetY,
                    min: -100,
                    max: 100,
                    divisions: 200,
                    onChanged: (value) async {
                      setState(() => _wallpaperOffsetY = value);
                      await controller.updateWallpaperOffset(_wallpaperOffsetX, _wallpaperOffsetY);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWallpaperBlur(ThemeSettingsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('高斯模糊', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _wallpaperBlur,
                min: 0,
                max: 20,
                divisions: 20,
                label: '${_wallpaperBlur.toStringAsFixed(1)}',
                onChanged: (value) async {
                  setState(() => _wallpaperBlur = value);
                  await controller.updateWallpaperBlur(_wallpaperBlur);
                },
              ),
            ),
            SizedBox(
              width: 50,
              child: Text(
                '${_wallpaperBlur.toStringAsFixed(1)}',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWallpaperOverlay(ThemeSettingsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('遮罩明暗', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _wallpaperOverlayOpacity,
                min: 0,
                max: 1,
                divisions: 100,
                label: '${_wallpaperOverlayOpacity.toStringAsFixed(2)}',
                onChanged: (value) async {
                  setState(() => _wallpaperOverlayOpacity = value);
                  await controller.updateWallpaperOverlayOpacity(_wallpaperOverlayOpacity);
                },
              ),
            ),
            SizedBox(
              width: 50,
              child: Text(
                '${_wallpaperOverlayOpacity.toStringAsFixed(2)}',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectWallpaper(ThemeSettingsController controller) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _wallpaperPath = result.files.single.path;
      });
      await controller.updateWallpaperPath(_wallpaperPath);
    }
  }

  Future<void> _removeWallpaper(ThemeSettingsController controller) async {
    setState(() {
      _wallpaperPath = null;
    });
    await controller.updateWallpaperPath(null);
  }

  Future<void> _showWeatherApiUrlDialog() async {
    final TextEditingController controller = TextEditingController(text: _weatherApiUrl);
    
    final String? result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('设置天气API URL'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'https://restapi.amap.com/v3/weather/weatherInfo',
              border: OutlineInputBorder(),
            ),
            maxLines: 1,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
    
    if (result != null && result!.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('weatherApiUrl', result);
      setState(() {
        _weatherApiUrl = result;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('API URL已保存')),
        );
      }
    }
  }

  Future<void> _showWeatherApiKeyDialog() async {
    final TextEditingController controller = TextEditingController(text: _weatherApiKey);
    
    final String? result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('设置天气API Key'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: '请输入API Key',
              border: OutlineInputBorder(),
            ),
            maxLines: 1,
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
    
    if (result != null && result!.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('weatherApiKey', result);
      setState(() {
        _weatherApiKey = result;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('API Key已保存')),
        );
      }
    }
  }

  Widget _buildAboutCard() {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AboutPage(),
            ),
          );
        },
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '关于',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
