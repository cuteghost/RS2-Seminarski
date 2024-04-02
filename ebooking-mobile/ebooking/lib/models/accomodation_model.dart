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
}

class Location {
  String address;
  String cityId;

  Location({
    required this.address,
    required this.cityId,
  });
}

class AccommodationDetails {
  bool bathub;
  bool balcony;
  bool privateBathroom;
  bool ac;
  bool terrace;
  bool kitchen;
  bool privatePool;
  bool coffeeMachine;
  bool view;
  bool seaView;
  bool washingMachine;
  bool spaTub;
  bool soundProof;
  bool breakfast;

  AccommodationDetails({
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
}
