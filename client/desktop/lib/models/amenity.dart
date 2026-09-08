class Amenity {
  final String id;
  final String code;
  final String name;
  final int sortOrder;

  const Amenity({
    required this.id,
    required this.code,
    required this.name,
    this.sortOrder = 0,
  });

  factory Amenity.fromJson(Map<String, dynamic> json) {
    return Amenity(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'sortOrder': sortOrder,
      };

  static List<Amenity> listFrom(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(Amenity.fromJson)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }
}
