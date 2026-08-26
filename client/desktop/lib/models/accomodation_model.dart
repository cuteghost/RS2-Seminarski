import 'dart:convert';
import 'dart:typed_data';

import 'package:ebooking_desktop/models/location_model.dart';

/// Tipovi smještaja — ogledalo backend enum-a `Models.Domain.TypesOfAccommodation`.
/// Redoslijed MORA odgovarati backendu jer se enum serijalizuje kao int.
///
/// Upute 3.4: "Magic numbers (npr. statusId = 1, 2, 3) treba zamijeniti
/// enum-ima ili konstantama" — zato `TypesOfAccommodation.fromIndex` umjesto
/// golog int-a razbacanog po UI-ju.
enum TypesOfAccommodation {
  house('Kuća'),
  hotel('Hotel'),
  resort('Resort'),
  apartment('Apartman'),
  villa('Vila'),
  hostel('Hostel'),
  cottage('Vikendica'),
  penthouse('Penthouse');

  final String label;
  const TypesOfAccommodation(this.label);

  static TypesOfAccommodation fromIndex(int? index) {
    if (index == null || index < 0 || index >= values.length) {
      return TypesOfAccommodation.house;
    }
    return values[index];
  }
}

/// Slike smještaja.
///
/// BUGFIX / anti-pattern: raniji `AccommodationImages.fromJson` je za SVAKU
/// sliku pravio temp direktorij i pisao `.jpg` na disk — I/O usred parsiranja
/// JSON-a, na svaki fetch, bez ikakvog čišćenja. Sada slike ostaju u memoriji
/// kao `Uint8List` i prikazuju se preko `MemoryImage`. Nema disk zapisa,
/// nema temp smeća, dekodiranje se radi jednom (Upute Dodatak A.2).
class AccommodationImages {
  final List<Uint8List> images;

  const AccommodationImages({required this.images});

  bool get isEmpty => images.isEmpty;
  Uint8List? get first => images.isEmpty ? null : images.first;

  factory AccommodationImages.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AccommodationImages(images: []);

    final decoded = <Uint8List>[];
    // Ključevi su image1..imageN; `id` preskačemo. Sortiramo da redoslijed
    // slika bude stabilan između poziva.
    final keys = json.keys.where((k) => k.toLowerCase() != 'id').toList()
      ..sort();

    for (final key in keys) {
      final value = json[key];
      if (value is! String || value.isEmpty) continue;
      try {
        decoded.add(base64Decode(value));
      } on FormatException {
        // Neispravan base64 sa servera ne smije srušiti cijelu listu.
        continue;
      }
    }
    return AccommodationImages(images: decoded);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    for (var i = 0; i < images.length; i++) {
      map['image${i + 1}'] = base64Encode(images[i]);
    }
    return map;
  }
}

class AccommodationDetails {
  final int numberOfBeds;
  final bool bathub;
  final bool balcony;
  final bool privateBathroom;
  final bool ac;
  final bool terrace;
  final bool kitchen;
  final bool privatePool;
  final bool coffeeMachine;
  final bool view;
  final bool seaView;
  final bool washingMachine;
  final bool spaTub;
  final bool soundProof;
  final bool breakfast;

  const AccommodationDetails({
    this.numberOfBeds = 0,
    this.bathub = false,
    this.balcony = false,
    this.privateBathroom = false,
    this.ac = false,
    this.terrace = false,
    this.kitchen = false,
    this.privatePool = false,
    this.coffeeMachine = false,
    this.view = false,
    this.seaView = false,
    this.washingMachine = false,
    this.spaTub = false,
    this.soundProof = false,
    this.breakfast = false,
  });

  /// BUGFIX: ranije je svako polje čitano sa `as bool` bez null-provjere, pa
  /// je jedan `null` u odgovoru rušio cijeli parsing liste smještaja.
  factory AccommodationDetails.fromJson(Map<String, dynamic>? json) {
    bool flag(String key) => json?[key] == true;
    return AccommodationDetails(
      numberOfBeds: (json?['numberOfBeds'] as num?)?.toInt() ?? 0,
      bathub: flag('bathub'),
      balcony: flag('balcony'),
      privateBathroom: flag('privateBathroom'),
      ac: flag('ac'),
      terrace: flag('terrace'),
      kitchen: flag('kitchen'),
      privatePool: flag('privatePool'),
      coffeeMachine: flag('coffeeMachine'),
      view: flag('view'),
      seaView: flag('seaView'),
      washingMachine: flag('washingMachine'),
      spaTub: flag('spaTub'),
      soundProof: flag('soundProof'),
      breakfast: flag('breakfast'),
    );
  }

  Map<String, dynamic> toJson() => {
        'numberOfBeds': numberOfBeds,
        'bathub': bathub,
        'balcony': balcony,
        'privateBathroom': privateBathroom,
        'ac': ac,
        'terrace': terrace,
        'kitchen': kitchen,
        'privatePool': privatePool,
        'coffeeMachine': coffeeMachine,
        'view': view,
        'seaView': seaView,
        'washingMachine': washingMachine,
        'spaTub': spaTub,
        'soundProof': soundProof,
        'breakfast': breakfast,
      };

  /// Lista uključenih sadržaja, spremna za prikaz kao tagovi.
  List<String> get amenityLabels => <String, bool>{
        'Klima': ac,
        'Balkon': balcony,
        'Privatno kupatilo': privateBathroom,
        'Terasa': terrace,
        'Kuhinja': kitchen,
        'Privatni bazen': privatePool,
        'Aparat za kafu': coffeeMachine,
        'Pogled': view,
        'Pogled na more': seaView,
        'Veš mašina': washingMachine,
        'Spa kada': spaTub,
        'Kada': bathub,
        'Zvučna izolacija': soundProof,
        'Doručak': breakfast,
      }.entries.where((e) => e.value).map((e) => e.key).toList();
}

/// Odgovara `Models.DTO.AccommodationDTO.AccommodationGET`.
class AccommodationGET {
  final String id;
  final String name;

  /// Backend polje je `bool?` — `null` tretiramo kao neaktivno.
  /// BUGFIX: ranije `json['status'] as bool` -> crash na `null`.
  final bool status;
  final TypesOfAccommodation typeOfAccommodation;
  final double pricePerNight;
  final String description;
  final double reviewScore;
  final String ownerId;
  final Location location;
  final AccommodationDetails accommodationDetails;
  final String reviews;
  final AccommodationImages images;

  const AccommodationGET({
    required this.id,
    required this.name,
    required this.status,
    required this.typeOfAccommodation,
    required this.pricePerNight,
    required this.description,
    required this.reviewScore,
    required this.ownerId,
    required this.location,
    required this.accommodationDetails,
    required this.reviews,
    required this.images,
  });

  factory AccommodationGET.fromJson(Map<String, dynamic> json) {
    return AccommodationGET(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      status: json['status'] == true,
      typeOfAccommodation: TypesOfAccommodation.fromIndex(
        (json['typeOfAccommodation'] as num?)?.toInt(),
      ),
      pricePerNight: (json['pricePerNight'] as num?)?.toDouble() ?? 0,
      description: json['description']?.toString() ?? '',
      reviewScore: (json['reviewScore'] as num?)?.toDouble() ?? 0,
      ownerId: json['ownerId']?.toString() ?? '',
      location: json['location'] is Map<String, dynamic>
          ? Location.fromJson(json['location'] as Map<String, dynamic>)
          : const Location(latitude: 0, longitude: 0, address: ''),
      accommodationDetails: AccommodationDetails.fromJson(
        json['accommodationDetails'] as Map<String, dynamic>?,
      ),
      reviews: json['reviews']?.toString() ?? '',
      images: AccommodationImages.fromJson(
        json['accommodationImages'] as Map<String, dynamic>?,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        'name': name,
        'typeOfAccommodation': typeOfAccommodation.index,
        'pricePerNight': pricePerNight,
        'description': description,
        'reviewScore': reviewScore,
        'location': location.toJson(),
        'accommodationDetails': accommodationDetails.toJson(),
        'reviews': reviews,
        'accommodationImages': images.toJson(),
      };
}
