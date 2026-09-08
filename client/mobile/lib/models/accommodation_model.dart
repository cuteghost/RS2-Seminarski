import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ebooking/models/catalog_model.dart';
import 'package:ebooking/models/location_model.dart';

class AccommodationGET {
  String id;
  String name;
  bool status;
  String accommodationTypeId;
  String accommodationTypeName;
  double pricePerNight;
  String description;
  double reviewScore;
  Location location;
  AccommodationDetails accommodationDetails;
  String reviews;
  int imageCount;
  List<String> imageUrls;

  AccommodationGET({
    required this.id,
    required this.status,
    required this.reviews,
    required this.name,
    required this.accommodationTypeId,
    required this.accommodationTypeName,
    required this.pricePerNight,
    required this.description,
    required this.reviewScore,
    required this.location,
    required this.accommodationDetails,
    required this.imageCount,
    required this.imageUrls,
  });

  String? get firstImageUrl => imageUrls.isEmpty ? null : imageUrls.first;

  factory AccommodationGET.fromJson(Map<String, dynamic> json) {
    return AccommodationGET(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      status: json['status'] as bool? ?? false,
      accommodationTypeId: json['accommodationTypeId'] as String? ?? '',
      accommodationTypeName: json['accommodationTypeName'] as String? ?? '',
      pricePerNight: (json['pricePerNight'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      reviewScore: (json['reviewScore'] as num).toDouble(),
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
      accommodationDetails: AccommodationDetails.fromJson(
        json['accommodationDetails'] as Map<String, dynamic>?,
      ),
      reviews: json['reviews'] != null ? json['reviews'] as String : '',
      imageCount: (json['imageCount'] as num?)?.toInt() ?? 0,
      imageUrls:
          (json['imageUrls'] as List?)?.whereType<String>().toList() ??
          const <String>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'name': name,
      'accommodationTypeId': accommodationTypeId,
      'accommodationTypeName': accommodationTypeName,
      'pricePerNight': pricePerNight,
      'description': description,
      'reviewScore': reviewScore,
      'location': location.toJson(),
      'accommodationDetails': accommodationDetails.toJson(),
      'reviews': reviews,
      'imageCount': imageCount,
      'imageUrls': imageUrls,
    };
  }
}

class AccommodationDetails {
  String? id;
  int numberOfBeds;
  List<Amenity> amenities;

  AccommodationDetails({
    required this.numberOfBeds,
    required this.amenities,
    this.id,
  });

  factory AccommodationDetails.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return AccommodationDetails(numberOfBeds: 0, amenities: <Amenity>[]);
    }
    return AccommodationDetails(
      id: json['id'] as String?,
      numberOfBeds: (json['numberOfBeds'] as num?)?.toInt() ?? 0,
      amenities:
          (json['amenities'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(Amenity.fromJson)
              .toList() ??
          <Amenity>[],
    );
  }

  bool has(String code) => amenities.any((amenity) => amenity.code == code);

  Map<String, dynamic> toJson() {
    return {
      'numberOfBeds': numberOfBeds,
      'amenityIds': amenities.map((amenity) => amenity.id).toList(),
    };
  }
}

class AccommodationImages {
  List<String> base64Images;

  AccommodationImages({required this.base64Images});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> imagesMap = {};
    for (int i = 0; i < base64Images.length; i++) {
      imagesMap['image${i + 1}'] = base64Images[i];
    }
    return imagesMap;
  }

  static Future<String> encode(File image) async =>
      base64Encode(await image.readAsBytes());

  static String encodeBytes(Uint8List bytes) => base64Encode(bytes);
}

class AccommodationPATCH {
  String id;
  String name;
  bool status;
  String accommodationTypeId;
  double pricePerNight;
  String description;
  AccommodationDetails accommodationDetails;
  AccommodationImages? images;

  /// Sent only when the partner actually moved the listing. Left out, the
  /// server keeps the address it already has.
  Location? location;

  AccommodationPATCH({
    required this.id,
    required this.status,
    required this.name,
    required this.accommodationTypeId,
    required this.pricePerNight,
    required this.description,
    required this.accommodationDetails,
    required this.images,
    this.location,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> body = {
      'id': id,
      'status': status,
      'name': name,
      'accommodationTypeId': accommodationTypeId,
      'pricePerNight': pricePerNight,
      'description': description,
      'accommodationDetails': accommodationDetails.toJson(),
    };
    final AccommodationImages? replacement = images;
    if (replacement != null) {
      body['accommodationImages'] = replacement.toJson();
    }
    final Location? moved = location;
    if (moved != null) {
      body['location'] = moved.toJson();
    }
    return body;
  }
}

class AccommodationPOST {
  String name;
  String accommodationTypeId;
  double pricePerNight;
  String description;
  Location location;
  AccommodationDetails accommodationDetails;
  AccommodationImages images;

  AccommodationPOST({
    required this.name,
    required this.accommodationTypeId,
    required this.pricePerNight,
    required this.description,
    required this.location,
    required this.accommodationDetails,
    required this.images,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'accommodationTypeId': accommodationTypeId,
      'pricePerNight': pricePerNight,
      'description': description,
      'location': location.toJson(),
      'accommodationDetails': accommodationDetails.toJson(),
      'accommodationImages': images.toJson(),
    };
  }
}
