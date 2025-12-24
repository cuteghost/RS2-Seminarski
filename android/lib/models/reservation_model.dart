import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:ebooking/models/accomodation_model.dart';

class ReservationGET {
  final String id;
  final String accommodationId;
  final DateTime startDate;
  final DateTime endDate;
  final int numberOfGuests;
  final bool isRated;
  final AccommodationGET? accommodation;
  final File thumbnail;
  ReservationGET({
    required this.id,
    required this.accommodationId,
    required this.startDate,
    required this.endDate,
    required this.numberOfGuests,
    required this.isRated,
    required this.thumbnail,
    this.accommodation
  });
  
  factory ReservationGET.fromJson(Map<String, dynamic> json) {
    return ReservationGET(
      id: json['id'],
      accommodationId: json['accommodationId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      numberOfGuests: json['numberOfGuests'],
      isRated: json['isRated'],
      accommodation: AccommodationGET.fromJson(json['accommodation']),
      thumbnail: base64ToImage(json['thumbnail'], Random().toString())
    );
  }
   static File base64ToImage(String base64image, String key) {
    List<int> imageBytes = base64Decode(base64image);
    Directory tempDir = Directory.systemTemp.createTempSync('thumbnailImages');
    File imageFile = File('${tempDir.path}/thumbnail$key.jpg');
    imageFile.writeAsBytesSync(imageBytes);
    return imageFile;
  }
}
class ReservationPOST {
  final String accommodationId;
  final DateTime startDate;
  final DateTime endDate;
  final int numberOfGuests;
  
  ReservationPOST({
    required this.accommodationId,
    required this.startDate,
    required this.endDate,
    required this.numberOfGuests
  });
  
  Map<String, dynamic> toJson() {
    return {
      'AccommodationId': accommodationId,
      'StartDate': startDate.toIso8601String(),
      'EndDate': endDate.toIso8601String(),
      'NumberOfGuests': numberOfGuests
    };
  }
}
class ReservationPATCH {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final int numberOfGuests;
  
  ReservationPATCH({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.numberOfGuests
  });
  
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'StartDate': startDate.toIso8601String(),
      'EndDate': endDate.toIso8601String(),
      'NumberOfGuests': numberOfGuests
    };
  }
}