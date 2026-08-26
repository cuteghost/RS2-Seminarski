/// Odgovara backend DTO-u `Models.DTO.LocationDTO.LocationGET`
/// { longitude, latitude, address, cityName, countryName }.
///
/// BUGFIX: raniji `fromJson` je radio `json['latitude'] as double` — što baca
/// `TypeError` čim backend serijalizuje cijeli broj (npr. `43` umjesto `43.0`),
/// jer JSON tada dekodira u `int`. Sada ide preko `num?.toDouble()`.
///
/// BUGFIX: `cityName` / `countryName` se ranije uopšte nisu čitali, pa je
/// desktop imao samo ulicu i nije mogao prikazati "Grad, Država" kolonu
/// koju dizajn traži.
class Location {
  final double latitude;
  final double longitude;
  final String address;
  final String cityName;
  final String countryName;

  /// Backend `LocationGET` ovo ne vraća; ostaje za POST/PATCH smjer.
  final String cityId;

  const Location({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.cityName = '',
    this.countryName = '',
    this.cityId = '',
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      address: json['address']?.toString() ?? '',
      cityName: json['cityName']?.toString() ?? '',
      countryName: json['countryName']?.toString() ?? '',
      cityId: json['cityId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'cityId': cityId,
      };

  /// "Sarajevo, Bosna i Hercegovina" — prazni dijelovi se izostavljaju,
  /// pa se nikad ne prikazuje ", " ili viseći zarez.
  String get placeLabel {
    final parts = [cityName, countryName].where((p) => p.isNotEmpty).toList();
    return parts.isEmpty ? '—' : parts.join(', ');
  }
}
