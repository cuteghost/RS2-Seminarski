import 'package:ebooking/models/accommodation_model.dart';

enum ReservationStatus {
  pending(1, 'Awaiting host'),
  confirmed(2, 'Confirmed'),
  cancelled(3, 'Cancelled'),
  rejected(4, 'Declined'),
  completed(5, 'Completed'),
  unknown(0, 'Unknown');

  const ReservationStatus(this.value, this.label);

  final int value;
  final String label;

  static ReservationStatus fromValue(int value) => values.firstWhere(
    (status) => status.value == value,
    orElse: () => unknown,
  );
}

class ReservationGuest {
  final String userId;
  final String displayName;
  final String firstName;
  final String lastName;
  final String email;
  final String? imageUrl;

  ReservationGuest({
    required this.userId,
    required this.displayName,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.imageUrl,
  });

  String get name {
    final full = '$firstName $lastName'.trim();
    if (full.isNotEmpty) return full;
    return displayName.isEmpty ? 'Guest' : displayName;
  }

  factory ReservationGuest.fromJson(Map<String, dynamic> json) {
    return ReservationGuest(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

class ReservationGET {
  final String id;
  final String accommodationId;
  final DateTime startDate;
  final DateTime endDate;
  final int numberOfGuests;
  final bool isRated;
  final bool isPaid;
  final double pricePerNight;
  final double totalPrice;
  final ReservationStatus status;
  final DateTime? statusChangedAt;
  final String? statusReason;
  final AccommodationGET? accommodation;
  final String? thumbnailUrl;
  final ReservationGuest? guest;
  ReservationGET({
    required this.id,
    required this.accommodationId,
    required this.startDate,
    required this.endDate,
    required this.numberOfGuests,
    required this.isRated,
    required this.isPaid,
    required this.pricePerNight,
    required this.totalPrice,
    required this.status,
    this.thumbnailUrl,
    this.statusChangedAt,
    this.statusReason,
    this.accommodation,
    this.guest,
  });

  bool get isActive =>
      status == ReservationStatus.pending ||
      status == ReservationStatus.confirmed;

  factory ReservationGET.fromJson(Map<String, dynamic> json) {
    return ReservationGET(
      id: json['id'],
      accommodationId: json['accommodationId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      numberOfGuests: json['numberOfGuests'],
      isRated: json['isRated'],
      isPaid: json['isPaid'] as bool? ?? false,
      pricePerNight: (json['pricePerNight'] as num?)?.toDouble() ?? 0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0,
      status: ReservationStatus.fromValue(
        (json['status'] as num?)?.toInt() ?? ReservationStatus.unknown.value,
      ),
      statusChangedAt: json['statusChangedAt'] == null
          ? null
          : DateTime.parse(json['statusChangedAt'] as String),
      statusReason: json['statusReason'] as String?,
      accommodation: AccommodationGET.fromJson(json['accommodation']),
      thumbnailUrl: json['thumbnailUrl'] as String?,
      guest: json['guest'] == null
          ? null
          : ReservationGuest.fromJson(json['guest'] as Map<String, dynamic>),
    );
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
    required this.numberOfGuests,
  });

  Map<String, dynamic> toJson() {
    return {
      'AccommodationId': accommodationId,
      'StartDate': startDate.toIso8601String(),
      'EndDate': endDate.toIso8601String(),
      'NumberOfGuests': numberOfGuests,
    };
  }
}

class ReservationStatusPATCH {
  final String reservationId;
  final ReservationStatus status;
  final String? reason;

  ReservationStatusPATCH({
    required this.reservationId,
    required this.status,
    this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'reservationId': reservationId,
      'status': status.value,
      if (reason != null && reason!.isNotEmpty) 'reason': reason,
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
    required this.numberOfGuests,
  });

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'StartDate': startDate.toIso8601String(),
      'EndDate': endDate.toIso8601String(),
      'NumberOfGuests': numberOfGuests,
    };
  }
}
