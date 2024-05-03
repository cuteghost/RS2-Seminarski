class City {
  final String id;
  final String name;
  final String countryName;

  City({
    required this.id, 
    required this.name,
    required this.countryName,
    });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      countryName: json['countryName'] as String? ?? '',
    );
  }
}
