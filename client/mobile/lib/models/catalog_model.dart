class AccommodationType {
  final String id;
  final String name;
  final int sortOrder;

  AccommodationType({
    required this.id,
    required this.name,
    required this.sortOrder,
  });

  factory AccommodationType.fromJson(Map<String, dynamic> json) {
    return AccommodationType(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }
}

class Amenity {
  final String id;
  final String code;
  final String name;
  final int sortOrder;

  Amenity({
    required this.id,
    required this.code,
    required this.name,
    required this.sortOrder,
  });

  factory Amenity.fromJson(Map<String, dynamic> json) {
    return Amenity(
      id: json['id'] as String,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }
}
