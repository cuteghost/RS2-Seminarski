import 'dart:convert';
import 'dart:typed_data';

import 'package:ebooking_desktop/models/accomodation_model.dart';

/// Odgovara backend DTO-u `Models.DTO.ReservationDTO.ReservationGET`.
///
/// BUGFIX: `thumbnail` je ranije bio `File` koji je `fromJson` pisao na disk
/// preko `Directory.systemTemp.createTempSync(...)` — i to sa `Random().toString()`
/// kao imenom, što je pravilo novi temp folder po rezervaciji, na svaki fetch,
/// bez brisanja. Sada ostaje `Uint8List?` u memoriji.
///
/// BUGFIX: `accommodation` je bio deklarisan kao nullable, ali je `fromJson`
/// bezuslovno radio `AccommodationGET.fromJson(json['accommodation'])` — što je
/// bacalo `TypeError` na svakoj rezervaciji bez učitanog smještaja.
class ReservationGET {
  final String id;
  final String accommodationId;
  final DateTime startDate;
  final DateTime endDate;
  final int numberOfGuests;
  final bool isRated;
  final AccommodationGET? accommodation;
  final Uint8List? thumbnail;

  const ReservationGET({
    required this.id,
    required this.accommodationId,
    required this.startDate,
    required this.endDate,
    required this.numberOfGuests,
    required this.isRated,
    this.accommodation,
    this.thumbnail,
  });

  factory ReservationGET.fromJson(Map<String, dynamic> json) {
    Uint8List? thumb;
    final rawThumb = json['thumbnail'];
    if (rawThumb is String && rawThumb.isNotEmpty) {
      try {
        thumb = base64Decode(rawThumb);
      } on FormatException {
        thumb = null;
      }
    } else if (rawThumb is List) {
      thumb = Uint8List.fromList(
          rawThumb.whereType<num>().map((n) => n.toInt()).toList());
    }

    DateTime parseDate(dynamic value) =>
        DateTime.tryParse(value?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);

    return ReservationGET(
      id: json['id']?.toString() ?? '',
      accommodationId: json['accommodationId']?.toString() ?? '',
      startDate: parseDate(json['startDate']),
      endDate: parseDate(json['endDate']),
      numberOfGuests: (json['numberOfGuests'] as num?)?.toInt() ?? 0,
      isRated: json['isRated'] == true,
      accommodation: json['accommodation'] is Map<String, dynamic>
          ? AccommodationGET.fromJson(
              json['accommodation'] as Map<String, dynamic>)
          : null,
      thumbnail: thumb,
    );
  }

  /// Broj noćenja — koristi se u izvještaju o prihodu.
  int get nights {
    final diff = endDate.difference(startDate).inDays;
    return diff <= 0 ? 1 : diff;
  }

  /// Procijenjeni prihod rezervacije.
  ///
  /// NAPOMENA: ovo je IZRAČUNATA cijena (noćenja × cijena po noći), a ne
  /// stvarno naplaćeni iznos — `ReservationGET` nema polje sa naplaćenim
  /// iznosom. Upute 7.1 traže da se refund radi "na osnovu stvarno naplaćenog
  /// iznosa, a ne kalkulisane cijene", pa je ovo prijavljeno kao nedostajuće
  /// backend polje. Izvještaj to i navodi u fusnoti.
  double get estimatedRevenue => (accommodation?.pricePerNight ?? 0) * nights;
}

class ReservationPOST {
  final String accommodationId;
  final DateTime startDate;
  final DateTime endDate;
  final int numberOfGuests;

  const ReservationPOST({
    required this.accommodationId,
    required this.startDate,
    required this.endDate,
    required this.numberOfGuests,
  });

  Map<String, dynamic> toJson() => {
        'AccommodationId': accommodationId,
        'StartDate': startDate.toIso8601String(),
        'EndDate': endDate.toIso8601String(),
        'NumberOfGuests': numberOfGuests,
      };
}

class ReservationPATCH {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final int numberOfGuests;

  const ReservationPATCH({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.numberOfGuests,
  });

  Map<String, dynamic> toJson() => {
        'Id': id,
        'StartDate': startDate.toIso8601String(),
        'EndDate': endDate.toIso8601String(),
        'NumberOfGuests': numberOfGuests,
      };
}
