class Country {
  final int id;
  final String name;
  Country({required this.name, required this.id});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'],
      name: json['name'],
    );
  }
}
