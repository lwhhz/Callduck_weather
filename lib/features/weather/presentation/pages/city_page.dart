import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:callduck_weather/features/weather/presentation/providers/city_provider.dart';
import 'package:callduck_weather/features/weather/domain/models/city.dart';

class CityPage extends ConsumerStatefulWidget {
  const CityPage({super.key});

  @override
  ConsumerState<CityPage> createState() => _CityPageState();
}

class _CityPageState extends ConsumerState<CityPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchKeyword = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cityList = ref.watch(cityListProvider);
    final selectedCity = ref.watch(selectedCityProvider);
    final citySearchAsync = _searchKeyword.isNotEmpty
        ? ref.watch(citySearchProvider(_searchKeyword))
        : null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 搜索栏
            Container(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '搜索城市...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchKeyword.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchKeyword = '';
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchKeyword = value;
                  });
                },
              ),
            ),
            
            // 搜索结果或城市列表
            Expanded(
              child: _searchKeyword.isNotEmpty
                  ? _buildSearchResults(citySearchAsync)
                  : _buildCityList(cityList, selectedCity),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(AsyncValue<List<City>>? searchAsync) {
    if (searchAsync == null) return const SizedBox.shrink();

    return searchAsync.when(
      data: (cities) {
        if (cities.isEmpty) {
          return const Center(
            child: Text('未找到相关城市'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: cities.length,
          itemBuilder: (context, index) {
            final city = cities[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(city.name),
                subtitle: Text(city.toString()),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    await ref.read(cityListProvider.notifier).addCity(city);
                    _searchController.clear();
                    setState(() {
                      _searchKeyword = '';
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('已添加 ${city.name}')),
                      );
                    }
                  },
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Text('搜索失败: $error'),
      ),
    );
  }

  Widget _buildCityList(List<City> cityList, City? selectedCity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 热门城市
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '热门城市',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ref.read(cityApiServiceProvider).getHotCities().map((city) {
              final isAdded = cityList.any((c) => c.adcode == city.adcode);
              return ActionChip(
                label: Text(city.name),
                onPressed: isAdded
                    ? null
                    : () async {
                        await ref.read(cityListProvider.notifier).addCity(city);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('已添加 ${city.name}')),
                          );
                        }
                      },
                backgroundColor: isAdded
                    ? Theme.of(context).colorScheme.surfaceVariant
                    : Theme.of(context).colorScheme.primaryContainer,
              );
            }).toList(),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 我的城市
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '我的城市',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        Expanded(
          child: cityList.isEmpty
              ? const Center(
                  child: Text('还没有添加城市，请搜索添加'),
                )
              : ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: cityList.length,
                  onReorder: (oldIndex, newIndex) async {
                    await ref
                        .read(cityListProvider.notifier)
                        .reorderCities(oldIndex, newIndex);
                  },
                  proxyDecorator: (child, index, animation) {
                    return Material(
                      color: Colors.transparent,
                      child: child,
                    );
                  },
                  itemBuilder: (context, index) {
                    final city = cityList[index];
                    final isSelected = selectedCity?.adcode == city.adcode;

                    return Card(
                      key: ValueKey(city.adcode),
                      margin: const EdgeInsets.only(bottom: 8),
                      color: isSelected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      child: ListTile(
                        title: Text(
                          city.name,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(city.toString()),
                        leading: isSelected
                            ? Icon(
                                Icons.location_on,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : const Icon(Icons.location_on_outlined),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isSelected)
                              TextButton(
                                onPressed: () async {
                                  await ref
                                      .read(selectedCityProvider.notifier)
                                      .selectCity(city);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('已切换到 ${city.name}')),
                                    );
                                  }
                                },
                                child: const Text('查看天气'),
                              ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () async {
                                await ref
                                    .read(cityListProvider.notifier)
                                    .removeCity(city);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('已删除 ${city.name}')),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
