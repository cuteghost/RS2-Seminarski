class AccommodationType {
  final String id;
  final String name;
  final int sortOrder;

  const AccommodationType({
    required this.id,
    required this.name,
    this.sortOrder = 0,
  });

  factory AccommodationType.fromJson(Map<String, dynamic> json) {
    return AccommodationType(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'sortOrder': sortOrder,
      };

  static List<AccommodationType> listFrom(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(AccommodationType.fromJson)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }
}
