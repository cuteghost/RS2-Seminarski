import 'package:ebooking/models/location_model.dart';

class Accommodation {
  String name;
  bool status;
  int typeOfAccommodation;
  double pricePerNight;
  String imageThumb;
  String description;
  double reviewScore;
  Location location;
  AccommodationDetails accommodationDetails;
  String image;
  String reviews;

  Accommodation({
    required this.name,
    required this.status,
    required this.typeOfAccommodation,
    required this.pricePerNight,
    required this.imageThumb,
    required this.description,
    required this.reviewScore,
    required this.location,
    required this.accommodationDetails,
    required this.image,
    required this.reviews,
  });

  factory Accommodation.fromJson(Map<String, dynamic> json) {
    return Accommodation(
      name: json['name'] as String,
      status: json['status'] as bool,
      typeOfAccommodation: json['typeOfAccommodation'] as int,
      pricePerNight: json['pricePerNight'] as double,
      imageThumb: json['imageThumb'] as String,
      description: json['description'] as String,
      reviewScore: json['reviewScore'] as double,
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
      image: json['image'] as String,
      reviews: json['reviews'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'status': status,
      'typeOfAccommodation': typeOfAccommodation,
      'pricePerNight': pricePerNight,
      'imageThumb': imageThumb,
      'description': description,
      'reviewScore': reviewScore,
      'location': location.toJson(),
      'accommodationDetails': accommodationDetails.toJson(),
      'image': image,
      'reviews': reviews,
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
