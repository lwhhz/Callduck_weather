import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:callduck_weather/app/routes/router.dart';
import 'package:callduck_weather/app/providers/theme_provider.dart';
import 'package:callduck_weather/app/themes/theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettingsAsync = ref.watch(themeSettingsControllerProvider);

    return themeSettingsAsync.when(
      data: (themeSettings) {
        final wallpaperPath = themeSettings.wallpaperSettings.enabled 
            ? themeSettings.wallpaperSettings.imagePath 
            : null;
        
        return FutureBuilder(
          future: Future.wait([
            AppTheme.generateTheme(
              Brightness.light,
              themeSettings.monetEnabled,
              themeSettings.preset,
              themeSettings.customColor,
              wallpaperPath,
            ),
            AppTheme.generateTheme(
              Brightness.dark,
              themeSettings.monetEnabled,
              themeSettings.preset,
              themeSettings.customColor,
              wallpaperPath,
            ),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return MaterialApp(
                home: Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
              );
            }
            
            if (snapshot.hasError) {
              return MaterialApp(
                home: Scaffold(
                  body: Center(child: Text('生成主题失败: ${snapshot.error}')),
                ),
              );
            }

            final themes = snapshot.data as List<ThemeData>;
            
            return MaterialApp.router(
              title: '天气应用',
              theme: themes[0],
              darkTheme: themes[1],
              routerConfig: appRouter,
            );
          },
        );
      },
      loading: () => MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => MaterialApp(
        home: Scaffold(
          body: Center(child: Text('加载主题设置失败: $error')),
        ),
      ),
    );
  }
}
