import 'package:ebooking_desktop/models/accomodation_model.dart';

enum ReservationStatus {
  pending(1, 'Pending'),
  confirmed(2, 'Confirmed'),
  cancelled(3, 'Cancelled'),
  rejected(4, 'Rejected'),
  completed(5, 'Completed');

  final int value;
  final String label;

  const ReservationStatus(this.value, this.label);

  static ReservationStatus? fromJson(dynamic raw) {
    if (raw is! num) return null;
    final value = raw.toInt();
    for (final status in values) {
      if (status.value == value) return status;
    }
    return null;
  }

  bool get isFinal =>
      this == cancelled || this == rejected || this == completed;
}

class ReservationGuest {
  final String userId;
  final String displayName;
  final String email;
  final String? imageUrl;

  const ReservationGuest({
    required this.userId,
    required this.displayName,
    required this.email,
    this.imageUrl,
  });

  factory ReservationGuest.fromJson(Map<String, dynamic> json) {
    final url = json['imageUrl']?.toString();
    return ReservationGuest(
      userId: json['userId']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      imageUrl: (url == null || url.isEmpty) ? null : url,
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
  final double pricePerNight;
  final double totalPrice;
  final ReservationStatus? status;
  final DateTime? statusChangedAt;
  final String statusReason;
  final bool isPaid;
  final AccommodationGET? accommodation;
  final String? thumbnailUrl;
  final ReservationGuest? guest;

  const ReservationGET({
    required this.id,
    required this.accommodationId,
    required this.startDate,
    required this.endDate,
    required this.numberOfGuests,
    required this.isRated,
    required this.pricePerNight,
    required this.totalPrice,
    required this.status,
    required this.statusChangedAt,
    required this.statusReason,
    required this.isPaid,
    this.accommodation,
    this.thumbnailUrl,
    this.guest,
  });

  factory ReservationGET.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) =>
        DateTime.tryParse(value?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);

    final rawThumb = json['thumbnailUrl']?.toString();

    return ReservationGET(
      id: json['id']?.toString() ?? '',
      accommodationId: json['accommodationId']?.toString() ?? '',
      startDate: parseDate(json['startDate']),
      endDate: parseDate(json['endDate']),
      numberOfGuests: (json['numberOfGuests'] as num?)?.toInt() ?? 0,
      isRated: json['isRated'] == true,
      pricePerNight: (json['pricePerNight'] as num?)?.toDouble() ?? 0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0,
      status: ReservationStatus.fromJson(json['status']),
      statusChangedAt: DateTime.tryParse(json['statusChangedAt']?.toString() ?? ''),
      statusReason: json['statusReason']?.toString() ?? '',
      isPaid: json['isPaid'] == true,
      accommodation: json['accommodation'] is Map<String, dynamic>
          ? AccommodationGET.fromJson(
              json['accommodation'] as Map<String, dynamic>)
          : null,
      thumbnailUrl: (rawThumb == null || rawThumb.isEmpty) ? null : rawThumb,
      guest: json['guest'] is Map<String, dynamic>
          ? ReservationGuest.fromJson(json['guest'] as Map<String, dynamic>)
          : null,
    );
  }

  int get nights {
    final diff = endDate.difference(startDate).inDays;
    return diff <= 0 ? 1 : diff;
  }

  double get revenue =>
      totalPrice > 0 ? totalPrice : (accommodation?.pricePerNight ?? 0) * nights;
}

class ReservationStatusHistoryGET {
  final String id;
  final String reservationId;
  final ReservationStatus? fromStatus;
  final ReservationStatus? toStatus;
  final String changedByDisplayName;
  final String changedByRole;
  final DateTime? changedAt;
  final String reason;

  const ReservationStatusHistoryGET({
    required this.id,
    required this.reservationId,
    required this.fromStatus,
    required this.toStatus,
    required this.changedByDisplayName,
    required this.changedByRole,
    required this.changedAt,
    required this.reason,
  });

  factory ReservationStatusHistoryGET.fromJson(Map<String, dynamic> json) {
    return ReservationStatusHistoryGET(
      id: json['id']?.toString() ?? '',
      reservationId: json['reservationId']?.toString() ?? '',
      fromStatus: ReservationStatus.fromJson(json['fromStatus']),
      toStatus: ReservationStatus.fromJson(json['toStatus']),
      changedByDisplayName:
          json['changedByDisplayName']?.toString() ?? 'Unknown user',
      changedByRole: json['changedByRole']?.toString() ?? '',
      changedAt: DateTime.tryParse(json['changedAt']?.toString() ?? ''),
      reason: json['reason']?.toString() ?? '',
    );
  }
}

enum PaymentStatus {
  none(0, 'Not started'),
  created(1, 'Started'),
  completed(2, 'Paid'),
  failed(3, 'Failed');

  final int value;
  final String label;

  const PaymentStatus(this.value, this.label);

  static PaymentStatus fromJson(dynamic raw) {
    if (raw is! num) return none;
    final value = raw.toInt();
    for (final status in values) {
      if (status.value == value) return status;
    }
    return none;
  }
}

class PaymentGET {
  final String reservationId;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final String provider;
  final DateTime? completedAt;
  final bool isPaid;

  const PaymentGET({
    required this.reservationId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.provider,
    required this.completedAt,
    required this.isPaid,
  });

  factory PaymentGET.fromJson(Map<String, dynamic> json) {
    final completed = DateTime.tryParse(json['completedAt']?.toString() ?? '');

    return PaymentGET(
      reservationId: json['reservationId']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency']?.toString() ?? '',
      status: PaymentStatus.fromJson(json['status']),
      provider: json['provider']?.toString() ?? '',
      completedAt: (completed == null || completed.year < 2000) ? null : completed,
      isPaid: json['isPaid'] == true,
    );
  }
}
