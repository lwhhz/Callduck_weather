import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_page.dart';
import 'city_page.dart';
import 'settings_page.dart';
import 'package:callduck_weather/app/providers/navigation_provider.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationControllerProvider);
    final List<Widget> _pages = [
      const HomePage(),
      const CityPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      body: _pages[currentIndex],
      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(top: BorderSide(
            color: Theme.of(context).colorScheme.surfaceVariant,
            width: 1,
          )),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: currentIndex * (MediaQuery.of(context).size.width / 3) + 20,
              bottom: 10,
              child: Container(
                width: MediaQuery.of(context).size.width / 3 - 40,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(context, ref, 0, '天气'),
                _buildNavItem(context, ref, 1, '城市'),
                _buildNavItem(context, ref, 2, '设置'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, WidgetRef ref, int index, String title) {
    final isSelected = ref.watch(navigationControllerProvider) == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(navigationControllerProvider.notifier).setPageIndex(index);
        },
        child: Container(
          height: 70,
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected 
                  ? Colors.white 
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      ),
    );
  }
}
