class City {
  final String adcode;
  final String name;
  final String? province;
  final String? city;
  final String? district;

  const City({
    required this.adcode,
    required this.name,
    this.province,
    this.city,
    this.district,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      adcode: json['adcode'] ?? '',
      name: json['name'] ?? '',
      province: json['province'],
      city: json['city'],
      district: json['district'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'adcode': adcode,
      'name': name,
      'province': province,
      'city': city,
      'district': district,
    };
  }

  @override
  String toString() {
    if (district != null && city != null && province != null) {
      return '$province $city $district';
    } else if (city != null && province != null) {
      return '$province $city';
    } else if (province != null) {
      return province!;
    }
    return name;
  }
}
