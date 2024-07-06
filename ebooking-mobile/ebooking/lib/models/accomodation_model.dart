import 'dart:convert';
import 'dart:io';

import 'package:ebooking/models/location_model.dart';

class AccommodationGET {
  String id;
  String name;
  bool status;
  int typeOfAccommodation;
  double pricePerNight;
  String description;
  double reviewScore;
  Location location;
  AccommodationDetails accommodationDetails;
  String reviews;
  AccommodationImages images;

  AccommodationGET({
    required this.id,
    required this.status,
    required this.reviews,
    required this.name,
    required this.typeOfAccommodation,
    required this.pricePerNight,
    required this.description,
    required this.reviewScore,
    required this.location,
    required this.accommodationDetails,
    required this.images,
  });

  factory AccommodationGET.fromJson(Map<String, dynamic> json) {
    return AccommodationGET(
      id: json['id'] as String,
      name: json['name'] as String,
      status: json['status'] as bool,
      typeOfAccommodation: json['typeOfAccommodation'] as int,
      pricePerNight: (json['pricePerNight'] as num).toDouble(),
      description: json['description'] as String,
      reviewScore: (json['reviewScore'] as num).toDouble(),
      location: Location.fromJson(json['location'] as Map<String, dynamic>),
      accommodationDetails: AccommodationDetails(
        numberOfBeds: json['accommodationDetails']['numberOfBeds'] as int,
        bathub: json['accommodationDetails']['bathub'] as bool,
        balcony: json['accommodationDetails']['balcony'] as bool,
        privateBathroom: json['accommodationDetails']['privateBathroom'] as bool,
        ac: json['accommodationDetails']['ac'] as bool,
        terrace: json['accommodationDetails']['terrace'] as bool,
        kitchen: json['accommodationDetails']['kitchen'] as bool,
        privatePool: json['accommodationDetails']['privatePool'] as bool,
        coffeeMachine: json['accommodationDetails']['coffeeMachine'] as bool,
        view: json['accommodationDetails']['view'] as bool,
        seaView: json['accommodationDetails']['seaView'] as bool,
        washingMachine: json['accommodationDetails']['washingMachine'] as bool,
        spaTub: json['accommodationDetails']['spaTub'] as bool,
        soundProof: json['accommodationDetails']['soundProof'] as bool,
        breakfast: json['accommodationDetails']['breakfast'] as bool,
      ),
      reviews: json['reviews'] != null ? json['reviews'] as String : '',
      images: json['accommodationImages'] != null ? AccommodationImages.fromJson(json['accommodationImages'] as Map<String, dynamic>) : AccommodationImages(images: []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'name': name,
      'typeOfAccommodation': typeOfAccommodation,
      'pricePerNight': pricePerNight,
      'description': description,
      'reviewScore': reviewScore,
      'location': location.toJson(),
      'accommodationDetails': accommodationDetails.toJson(),
      'reviews': reviews,
      'accommodationImages': images.toJson(),
    };
  }
}

class AccommodationDetails {
  int numberOfBeds;
  bool bathub = false;
  bool balcony = false;
  bool privateBathroom = false;
  bool ac = false;
  bool terrace = false;
  bool kitchen = false;
  bool privatePool = false;
  bool coffeeMachine = false;
  bool view = false;
  bool seaView = false;
  bool washingMachine = false;
  bool spaTub = false;
  bool soundProof = false;
  bool breakfast = false;

  AccommodationDetails({
    required this.numberOfBeds,
    required this.bathub,
    required this.balcony,
    required this.privateBathroom,
    required this.ac,
    required this.terrace,
    required this.kitchen,
    required this.privatePool,
    required this.coffeeMachine,
    required this.view,
    required this.seaView,
    required this.washingMachine,
    required this.spaTub,
    required this.soundProof,
    required this.breakfast,
  });

   Map<String, dynamic> toJson() {
    return {
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
  }
}

class AccommodationImages {
  List<File?> images;

  AccommodationImages({required this.images});

  factory AccommodationImages.fromJson(Map<String, dynamic> json) {
    return AccommodationImages(
      images: json.keys
        .where((key) => key != 'id' && json[key] != null && json[key] as String != '')
        .map((key) => base64ToImage(json[key] as String, key))
        .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    List<String> imagesBase64 = [];
    images.forEach((element) { 
      imagesBase64.add(imageToBase64(element!));
    });
    Map<String, dynamic> imagesMap = {};
    for (int i = 0; i < imagesBase64.length; i++) {
      imagesMap['image${i + 1}'] = imagesBase64[i];
    }
    return imagesMap;
  }

  static String imageToBase64(File image) {
    List<int> imageBytes = image.readAsBytesSync();
    String base64image = base64Encode(imageBytes);
    return base64image;
  }

  static File base64ToImage(String base64image, String key) {
    List<int> imageBytes = base64Decode(base64image);
    Directory tempDir = Directory.systemTemp.createTempSync('accommodationImages');
    File imageFile = File('${tempDir.path}/accommodationImage$key.jpg');
    imageFile.writeAsBytesSync(imageBytes);
    return imageFile;
  }
}

class AccommodationPATCH {
  String id;
  String name;
  bool status;
  int typeOfAccommodation;
  double pricePerNight;
  String description;
  AccommodationDetails accommodationDetails;
  AccommodationImages images;

  AccommodationPATCH({
    required this.id,
    required this.status,
    required this.name,
    required this.typeOfAccommodation,
    required this.pricePerNight,
    required this.description,
    required this.accommodationDetails,
    required this.images,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'name': name,
      'typeOfAccommodation': typeOfAccommodation,
      'pricePerNight': pricePerNight,
      'description': description,
      'accommodationDetails': accommodationDetails.toJson(),
      'accommodationImages': images.toJson(),
    };
  }
}

class AccommodationPOST {
  String name;
  bool status;
  int typeOfAccommodation;
  double pricePerNight;
  String description;
  Location location;
  AccommodationDetails accommodationDetails;
  AccommodationImages images;

  AccommodationPOST({
    required this.status,
    required this.name,
    required this.typeOfAccommodation,
    required this.pricePerNight,
    required this.description,
    required this.location,
    required this.accommodationDetails,
    required this.images,
  });

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'name': name,
      'typeOfAccommodation': typeOfAccommodation,
      'pricePerNight': pricePerNight,
      'description': description,
      'location': location.toJson(),
      'accommodationDetails': accommodationDetails.toJson(),
      'accommodationImages': images.toJson(),
    };
  }
}

enum TypesOfAccommodation {
  House,
  Hotel,
  Resort,
  Apartment,
  Villa,
  Hostel,
  Cottage,
  Penthouse
}
