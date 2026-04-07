import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/weather/presentation/pages/main_page.dart';
import '../../features/weather/presentation/pages/home_page.dart';
import '../../features/weather/presentation/pages/city_page.dart';
import '../../features/weather/presentation/pages/settings_page.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainPage(),
    ),
  ],
);
