import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:callduck_weather/app/themes/theme.dart';
import 'package:callduck_weather/app/models/wallpaper_settings.dart';
import 'package:image/image.dart' as img;

class ThemeSettings {
  final bool monetEnabled;
  final ThemePreset? preset;
  final Color? customColor;
  final WallpaperSettings wallpaperSettings;
  final double cardOpacity;
  final Color? monetColor;

  ThemeSettings({
    required this.monetEnabled,
    this.preset,
    this.customColor,
    required this.wallpaperSettings,
    this.cardOpacity = 0.8,
    this.monetColor,
  });

  ThemeSettings copyWith({
    bool? monetEnabled,
    ThemePreset? preset,
    Color? customColor,
    WallpaperSettings? wallpaperSettings,
    double? cardOpacity,
    Color? monetColor,
  }) {
    return ThemeSettings(
      monetEnabled: monetEnabled ?? this.monetEnabled,
      preset: preset ?? this.preset,
      customColor: customColor ?? this.customColor,
      wallpaperSettings: wallpaperSettings ?? this.wallpaperSettings,
      cardOpacity: cardOpacity ?? this.cardOpacity,
      monetColor: monetColor ?? this.monetColor,
    );
  }
}

class ThemeSettingsController extends Notifier<AsyncValue<ThemeSettings>> {
  @override
  AsyncValue<ThemeSettings> build() {
    loadSettings();
    return const AsyncValue.loading();
  }

  Future<void> loadSettings() async {
    state = const AsyncValue.loading();
    try {
      final prefs = await SharedPreferences.getInstance();
      final monetEnabled = prefs.getBool('monetEnabled') ?? false;
      final presetIndex = prefs.getInt('themePreset');
      final customColorValue = prefs.getInt('customColor');

      ThemePreset? preset;
      if (presetIndex != null) {
        preset = ThemePreset.values[presetIndex];
      }

      Color? customColor;
      if (customColorValue != null) {
        customColor = Color(customColorValue);
      }

      final wallpaperEnabled = prefs.getBool('wallpaperEnabled') ?? false;
      final wallpaperPath = prefs.getString('wallpaperPath');
      final wallpaperOffsetX = prefs.getDouble('wallpaperOffsetX') ?? 0.0;
      final wallpaperOffsetY = prefs.getDouble('wallpaperOffsetY') ?? 0.0;
      final wallpaperBlur = prefs.getDouble('wallpaperBlur') ?? 0.0;
      final wallpaperOverlayOpacity = prefs.getDouble('wallpaperOverlayOpacity') ?? 0.3;
      final cardOpacity = prefs.getDouble('cardOpacity') ?? 0.8;

      final wallpaperSettings = WallpaperSettings(
        imagePath: wallpaperPath,
        offsetX: wallpaperOffsetX,
        offsetY: wallpaperOffsetY,
        blurAmount: wallpaperBlur,
        overlayOpacity: wallpaperOverlayOpacity,
        enabled: wallpaperEnabled,
      );

      Color? monetColor;
      if (monetEnabled && wallpaperPath != null) {
        monetColor = await _extractColorFromWallpaper(wallpaperPath);
      }

      state = AsyncValue.data(ThemeSettings(
        monetEnabled: monetEnabled,
        preset: preset,
        customColor: customColor,
        wallpaperSettings: wallpaperSettings,
        cardOpacity: cardOpacity,
        monetColor: monetColor,
      ));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<Color> _extractColorFromWallpaper(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        return Colors.blue;
      }

      int r = 0, g = 0, b = 0;
      int count = 0;

      for (int y = 0; y < image.height; y += 10) {
        for (int x = 0; x < image.width; x += 10) {
          final pixel = image.getPixel(x, y);
          r += pixel.r.toInt();
          g += pixel.g.toInt();
          b += pixel.b.toInt();
          count++;
        }
      }

      if (count > 0) {
        r = r ~/ count;
        g = g ~/ count;
        b = b ~/ count;
      }

      return Color.fromARGB(255, r, g, b);
    } catch (e) {
      return Colors.blue;
    }
  }

  Future<void> updateMonetEnabled(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('monetEnabled', value);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updatePreset(ThemePreset preset) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('themePreset', preset.index);
      await prefs.remove('customColor');
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateCustomColor(Color color) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('customColor', color.value);
      await prefs.remove('themePreset');
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateWallpaperEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('wallpaperEnabled', enabled);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateWallpaperPath(String? path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (path != null) {
        await prefs.setString('wallpaperPath', path);
      } else {
        await prefs.remove('wallpaperPath');
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateWallpaperOffset(double x, double y) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('wallpaperOffsetX', x);
      await prefs.setDouble('wallpaperOffsetY', y);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateWallpaperBlur(double blur) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('wallpaperBlur', blur);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateWallpaperOverlayOpacity(double opacity) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('wallpaperOverlayOpacity', opacity);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateCardOpacity(double opacity) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('cardOpacity', opacity);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

final themeSettingsControllerProvider = NotifierProvider<ThemeSettingsController, AsyncValue<ThemeSettings>>(() {
  return ThemeSettingsController();
});

final themeSettingsProvider = Provider<AsyncValue<ThemeSettings>>((ref) {
  return ref.watch(themeSettingsControllerProvider);
});
