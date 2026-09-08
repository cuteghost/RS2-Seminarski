/// Odgovara backend DTO-u `Models.DTO.CountryDTO.CountryGET` { id, name }.
///
/// NAPOMENA o omotaču: `/api/Country/*` od golden-template refaktora vraća
/// `BaseResponse<T>` / `PagedResponse<T>` — dakle `{ message, data }` odnosno
/// `{ message, data, page, pageSize, totalCount, totalPages }`. Odmotavanje
/// se radi u `services/location_service.dart`; ovdje `fromJson` prima već
/// odmotan objekat države.
class Country {
  final String id;
  final String name;

  const Country({required this.id, required this.name});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Country && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
