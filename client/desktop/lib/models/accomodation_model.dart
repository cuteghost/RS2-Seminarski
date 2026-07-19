import 'package:ebooking_desktop/models/amenity.dart';
import 'package:ebooking_desktop/models/location_model.dart';

class AccommodationDetails {
  final String id;
  final int numberOfBeds;
  final List<Amenity> amenities;

  const AccommodationDetails({
    this.id = '',
    this.numberOfBeds = 0,
    this.amenities = const [],
  });

  factory AccommodationDetails.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AccommodationDetails();

    return AccommodationDetails(
      id: json['id']?.toString() ?? '',
      numberOfBeds: (json['numberOfBeds'] as num?)?.toInt() ?? 0,
      amenities: Amenity.listFrom(json['amenities']),
    );
  }

  Map<String, dynamic> toJson() => {
        'numberOfBeds': numberOfBeds,
        'amenityIds': amenities.map((a) => a.id).toList(),
      };

  List<String> get amenityLabels =>
      amenities.map((a) => a.name).where((n) => n.isNotEmpty).toList();
}

class AccommodationGET {
  final String id;
  final String name;
  final bool status;
  final String accommodationTypeId;
  final String accommodationTypeName;
  final double pricePerNight;
  final String description;
  final double reviewScore;
  final String ownerId;
  final Location location;
  final int imageCount;
  final List<String> imageUrls;

  final AccommodationDetails accommodationDetails;

  const AccommodationGET({
    required this.id,
    required this.name,
    required this.status,
    required this.accommodationTypeId,
    required this.accommodationTypeName,
    required this.pricePerNight,
    required this.description,
    required this.reviewScore,
    required this.ownerId,
    required this.location,
    required this.imageCount,
    required this.imageUrls,
    required this.accommodationDetails,
  });

  factory AccommodationGET.fromJson(Map<String, dynamic> json) {
    final urls = json['imageUrls'];

    return AccommodationGET(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      status: json['status'] == true,
      accommodationTypeId: json['accommodationTypeId']?.toString() ?? '',
      accommodationTypeName: json['accommodationTypeName']?.toString() ?? '',
      pricePerNight: (json['pricePerNight'] as num?)?.toDouble() ?? 0,
      description: json['description']?.toString() ?? '',
      reviewScore: (json['reviewScore'] as num?)?.toDouble() ?? 0,
      ownerId: json['ownerId']?.toString() ?? '',
      location: json['location'] is Map<String, dynamic>
          ? Location.fromJson(json['location'] as Map<String, dynamic>)
          : const Location(latitude: 0, longitude: 0, address: ''),
      imageCount: (json['imageCount'] as num?)?.toInt() ?? 0,
      imageUrls: urls is List
          ? urls.map((u) => u.toString()).where((u) => u.isNotEmpty).toList()
          : const <String>[],
      accommodationDetails: AccommodationDetails.fromJson(
        json['accommodationDetails'] as Map<String, dynamic>?,
      ),
    );
  }

  bool get hasImages => imageCount > 0 && imageUrls.isNotEmpty;

  String get typeLabel =>
      accommodationTypeName.isEmpty ? 'Nepoznat tip' : accommodationTypeName;

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        'name': name,
        'accommodationTypeId': accommodationTypeId,
        'pricePerNight': pricePerNight,
        'description': description,
        'location': location.toJson(),
        'accommodationDetails': accommodationDetails.toJson(),
      };
}
