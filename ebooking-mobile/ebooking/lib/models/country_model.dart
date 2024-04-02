class Country {
  final String id;
  final String name;

  Country({required this.id, required this.name});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}
