class Location {
  double latitude;
  double longitude;
  String address;
  String cityId;

  /// Read-only labels the server already sends with every location. The edit
  /// form needs them to preselect the country and city dropdowns; they are not
  /// part of [toJson] because the server keys the location off [cityId].
  final String cityName;
  final String countryName;

  Location({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.cityId,
    this.cityName = '',
    this.countryName = '',
  });
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      address: json['address'] as String,
      cityId: json['cityId'] != null ? json['cityId'] as String : '',
      cityName: json['cityName'] as String? ?? '',
      countryName: json['countryName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'cityId': cityId,
    };
  }
}
