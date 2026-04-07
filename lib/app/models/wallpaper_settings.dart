import 'dart:ui';

class WallpaperSettings {
  final String? imagePath;
  final double offsetX;
  final double offsetY;
  final double blurAmount;
  final double overlayOpacity;
  final bool enabled;

  WallpaperSettings({
    this.imagePath,
    this.offsetX = 0.0,
    this.offsetY = 0.0,
    this.blurAmount = 0.0,
    this.overlayOpacity = 0.3,
    this.enabled = false,
  });

  WallpaperSettings copyWith({
    String? imagePath,
    double? offsetX,
    double? offsetY,
    double? blurAmount,
    double? overlayOpacity,
    bool? enabled,
  }) {
    return WallpaperSettings(
      imagePath: imagePath ?? this.imagePath,
      offsetX: offsetX ?? this.offsetX,
      offsetY: offsetY ?? this.offsetY,
      blurAmount: blurAmount ?? this.blurAmount,
      overlayOpacity: overlayOpacity ?? this.overlayOpacity,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imagePath': imagePath,
      'offsetX': offsetX,
      'offsetY': offsetY,
      'blurAmount': blurAmount,
      'overlayOpacity': overlayOpacity,
      'enabled': enabled,
    };
  }

  factory WallpaperSettings.fromJson(Map<String, dynamic> json) {
    return WallpaperSettings(
      imagePath: json['imagePath'] as String?,
      offsetX: (json['offsetX'] as num?)?.toDouble() ?? 0.0,
      offsetY: (json['offsetY'] as num?)?.toDouble() ?? 0.0,
      blurAmount: (json['blurAmount'] as num?)?.toDouble() ?? 0.0,
      overlayOpacity: (json['overlayOpacity'] as num?)?.toDouble() ?? 0.3,
      enabled: json['enabled'] as bool? ?? false,
    );
  }
}
