class City {
  final String id;
  final String name;
  final String countryId;
  final String countryName;

  const City({
    required this.id,
    required this.name,
    required this.countryId,
    required this.countryName,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      countryId: json['countryId']?.toString() ?? '',
      countryName: json['countryName']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'countryId': countryId,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is City && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
