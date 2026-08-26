/// Odgovara backend DTO-u `Models.DTO.CityDTO.CityGET` { id, name, countryName }.
///
/// `countryId` NIJE dio `CityGET`-a (backend ga trenutno ne vraća) — držimo ga
/// kao opcionalno polje da UI može filtrirati gradove po državi kad backend
/// prođe kroz golden-template refaktor. Do tada se filtriranje radi po
/// `countryName`. Vidi "Nedostajuće backend funkcionalnosti" u izvještaju.
class City {
  final String id;
  final String name;
  final String countryName;
  final String? countryId;

  const City({
    required this.id,
    required this.name,
    required this.countryName,
    this.countryId,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      countryName: json['countryName']?.toString() ?? '',
      countryId: json['countryId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'countryName': countryName,
        if (countryId != null) 'countryId': countryId,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is City && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
