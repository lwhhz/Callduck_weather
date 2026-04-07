import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

enum ThemePreset {
  blue,
  green,
  purple,
  orange,
  pink,
  teal,
}

Map<ThemePreset, Color> presetColors = {
  ThemePreset.blue: Colors.blue,
  ThemePreset.green: Colors.green,
  ThemePreset.purple: Colors.purple,
  ThemePreset.orange: Colors.orange,
  ThemePreset.pink: Colors.pink,
  ThemePreset.teal: Colors.teal,
};

class AppTheme {
  static Future<ThemeData> generateTheme(
    Brightness brightness,
    bool monetEnabled,
    ThemePreset? preset,
    Color? customColor,
    String? wallpaperPath,
  ) async {
    Color seedColor;

    if (monetEnabled && wallpaperPath != null) {
      seedColor = await _extractColorFromWallpaper(wallpaperPath!);
    } else if (monetEnabled) {
      seedColor = brightness == Brightness.light ? Colors.blue.shade400 : Colors.blue.shade700;
    } else if (customColor != null) {
      seedColor = customColor;
    } else if (preset != null) {
      seedColor = presetColors[preset]!;
    } else {
      seedColor = Colors.blue;
    }

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: brightness,
      ),
      useMaterial3: true,
      fontFamily: 'MiSans',
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(fontSize: 16),
        bodyMedium: TextStyle(fontSize: 14),
        bodySmall: TextStyle(fontSize: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static Future<Color> _extractColorFromWallpaper(String path) async {
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
}
