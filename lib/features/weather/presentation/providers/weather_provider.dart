import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:callduck_weather/features/weather/data/services/weather_api_service.dart';
import 'package:callduck_weather/features/weather/domain/models/weather.dart';
import 'city_provider.dart';

final weatherApiServiceProvider = Provider((ref) => WeatherApiService());

final currentWeatherProvider = FutureProvider<Weather>((ref) async {
  final apiService = ref.watch(weatherApiServiceProvider);
  final selectedCity = ref.watch(selectedCityProvider);
  final cityCode = selectedCity?.adcode ?? WeatherApiService.defaultCityCode;
  return apiService.getCurrentWeather(cityCode);
});

final hourlyForecastProvider = FutureProvider<List<HourlyForecast>>((ref) async {
  final apiService = ref.watch(weatherApiServiceProvider);
  final selectedCity = ref.watch(selectedCityProvider);
  final cityCode = selectedCity?.adcode ?? WeatherApiService.defaultCityCode;
  return apiService.getHourlyForecast(cityCode);
});

final dailyForecastProvider = FutureProvider<List<DailyForecast>>((ref) async {
  final apiService = ref.watch(weatherApiServiceProvider);
  final selectedCity = ref.watch(selectedCityProvider);
  final cityCode = selectedCity?.adcode ?? WeatherApiService.defaultCityCode;
  return apiService.getDailyForecast(cityCode);
});
