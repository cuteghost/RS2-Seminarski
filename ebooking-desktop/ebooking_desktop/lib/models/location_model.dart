class Location {
  double latitude;
  double longitude;
  String address;
  String cityId;

  Location({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.cityId,
  });
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      address: json['address'] as String,
      cityId: json['cityId'] != null ? json['cityId'] as String: '',
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