import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:callduck_weather/features/weather/data/services/city_api_service.dart';
import 'package:callduck_weather/features/weather/domain/models/city.dart';

final cityApiServiceProvider = Provider((ref) => CityApiService());

final cityListProvider = NotifierProvider<CityListNotifier, List<City>>(CityListNotifier.new);

final selectedCityProvider = NotifierProvider<SelectedCityNotifier, City?>(SelectedCityNotifier.new);

final citySearchProvider = FutureProvider.family<List<City>, String>((ref, keyword) async {
  final apiService = ref.read(cityApiServiceProvider);
  return await apiService.searchCity(keyword);
});

class CityListNotifier extends Notifier<List<City>> {
  @override
  List<City> build() {
    _loadCities();
    return [];
  }

  static const String _citiesKey = 'saved_cities';

  Future<void> _loadCities() async {
    final prefs = await SharedPreferences.getInstance();
    final citiesJson = prefs.getStringList(_citiesKey);
    
    if (citiesJson != null) {
      state = citiesJson
          .map((json) => City.fromJson(jsonDecode(json)))
          .toList();
    } else {
      // 默认添加北京
      state = const [City(adcode: '110000', name: '北京')];
      _saveCities();
    }
  }

  Future<void> _saveCities() async {
    final prefs = await SharedPreferences.getInstance();
    final citiesJson = state
        .map((city) => jsonEncode(city.toJson()))
        .toList();
    await prefs.setStringList(_citiesKey, citiesJson);
  }

  Future<void> addCity(City city) async {
    if (!state.any((c) => c.adcode == city.adcode)) {
      state = [...state, city];
      await _saveCities();
    }
  }

  Future<void> removeCity(City city) async {
    state = state.where((c) => c.adcode != city.adcode).toList();
    await _saveCities();
  }

  Future<void> reorderCities(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final cities = List<City>.from(state);
    final city = cities.removeAt(oldIndex);
    cities.insert(newIndex, city);
    state = cities;
    await _saveCities();
  }
}

class SelectedCityNotifier extends Notifier<City?> {
  @override
  City? build() {
    _loadSelectedCity();
    return null;
  }

  static const String _selectedCityKey = 'selected_city';

  Future<void> _loadSelectedCity() async {
    final prefs = await SharedPreferences.getInstance();
    final cityJson = prefs.getString(_selectedCityKey);
    
    if (cityJson != null) {
      state = City.fromJson(jsonDecode(cityJson));
    } else {
      // 默认选中北京
      state = const City(adcode: '110000', name: '北京');
    }
  }

  Future<void> selectCity(City city) async {
    state = city;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedCityKey, jsonEncode(city.toJson()));
  }
}
