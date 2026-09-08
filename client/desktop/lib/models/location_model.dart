class Location {
  final String id;
  final double latitude;
  final double longitude;
  final String address;
  final String cityId;
  final String cityName;
  final String countryName;
  final int accommodationCount;

  const Location({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.id = '',
    this.cityId = '',
    this.cityName = '',
    this.countryName = '',
    this.accommodationCount = 0,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      address: json['address']?.toString() ?? '',
      cityId: json['cityId']?.toString() ?? '',
      cityName: json['cityName']?.toString() ?? '',
      countryName: json['countryName']?.toString() ?? '',
      accommodationCount: (json['accommodationCount'] as num?)?.toInt() ?? 0,
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

  String get coordinatesLabel =>
      '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
}
