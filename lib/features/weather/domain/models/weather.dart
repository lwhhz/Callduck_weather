class Weather {
  final double temperature;
  final String condition;
  final int humidity;
  final double windSpeed;
  final String windDirection;
  final int pressure;
  final double precipitation;
  final String icon;
  final String cityName;
  final String provinceName;
  final DateTime reportTime;
  final DateTime timestamp;

  Weather({
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.pressure,
    required this.precipitation,
    required this.icon,
    required this.cityName,
    required this.provinceName,
    required this.reportTime,
    required this.timestamp,
  });
}

class HourlyForecast {
  final DateTime time;
  final double temperature;
  final String condition;
  final String icon;
  final double precipitation;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.condition,
    required this.icon,
    required this.precipitation,
  });
}

class DailyForecast {
  final DateTime date;
  final double maxTemperature;
  final double minTemperature;
  final String condition;
  final String icon;
  final double precipitation;

  DailyForecast({
    required this.date,
    required this.maxTemperature,
    required this.minTemperature,
    required this.condition,
    required this.icon,
    required this.precipitation,
  });
}
