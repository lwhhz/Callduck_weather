import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:callduck_weather/features/weather/domain/models/city.dart';

class CityApiService {
  static const String apiKey = '6899efde0bfdd085bece40d4fccf94a1';
  static const String geoUrl = 'https://restapi.amap.com/v3/geocode/geo';
  static const String districtUrl = 'https://restapi.amap.com/v3/config/district';

  /// 搜索城市
  Future<List<City>> searchCity(String keyword) async {
    if (keyword.isEmpty) return [];

    final url = '$districtUrl?key=$apiKey&keywords=$keyword&subdistrict=0&extensions=base';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('请求失败，状态码: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    
    if (data['status'] != '1' || data['districts'] == null) {
      return [];
    }

    final List<City> cities = [];
    for (final district in data['districts']) {
      cities.add(City(
        adcode: district['adcode'] ?? '',
        name: district['name'] ?? '',
        province: district['name'],
        city: district['name'],
        district: district['level'] == 'district' ? district['name'] : null,
      ));
    }

    return cities;
  }

  /// 获取城市详细信息
  Future<City?> getCityDetail(String adcode) async {
    final url = '$districtUrl?key=$apiKey&keywords=$adcode&subdistrict=0&extensions=base';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      return null;
    }

    final data = json.decode(response.body);
    
    if (data['status'] != '1' || data['districts'] == null || data['districts'].isEmpty) {
      return null;
    }

    final district = data['districts'][0];
    return City(
      adcode: district['adcode'] ?? '',
      name: district['name'] ?? '',
      province: district['name'],
      city: district['name'],
      district: district['level'] == 'district' ? district['name'] : null,
    );
  }

  /// 获取热门城市列表
  List<City> getHotCities() {
    return const [
      City(adcode: '110000', name: '北京'),
      City(adcode: '310000', name: '上海'),
      City(adcode: '440100', name: '广州'),
      City(adcode: '440300', name: '深圳'),
      City(adcode: '330100', name: '杭州'),
      City(adcode: '320100', name: '南京'),
      City(adcode: '510100', name: '成都'),
      City(adcode: '420100', name: '武汉'),
      City(adcode: '610100', name: '西安'),
      City(adcode: '500000', name: '重庆'),
      City(adcode: '120000', name: '天津'),
      City(adcode: '210100', name: '沈阳'),
    ];
  }
}
