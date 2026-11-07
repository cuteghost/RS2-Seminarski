import 'dart:convert';
import 'dart:typed_data';

class FeedbackPOST {
  final int rating;
  final bool satisfaction;
  final bool wouldRecommend;
  final String accommodationId;
  final String reservationId;
  final String? comment;
  final Uint8List? image;

  FeedbackPOST({
    required this.rating,
    required this.satisfaction,
    required this.wouldRecommend,
    required this.accommodationId,
    required this.reservationId,
    this.comment,
    this.image,
  });

  Map<String, dynamic> toJson() {
    final photo = image;
    return {
      'rating': rating,
      'satisfaction': satisfaction,
      'wouldRecommend': wouldRecommend,
      'accommodationId': accommodationId,
      'reservationId': reservationId,
      'comment': comment,
      if (photo != null && photo.isNotEmpty) 'image': base64Encode(photo),
    };
  }
}

class AccommodationReview {
  final String id;
  final String accommodationId;
  final String customerDisplayName;
  final int rating;
  final bool satisfaction;
  final bool wouldRecommend;
  final String comment;
  final String? imageUrl;

  AccommodationReview({
    required this.id,
    required this.accommodationId,
    required this.customerDisplayName,
    required this.rating,
    required this.satisfaction,
    required this.wouldRecommend,
    required this.comment,
    this.imageUrl,
  });

  factory AccommodationReview.fromJson(Map<String, dynamic> json) {
    return AccommodationReview(
      id: json['id'] as String,
      accommodationId: json['accommodationId'] as String,
      customerDisplayName: json['customerDisplayName'] as String? ?? '',
      rating: (json['rating'] as num).toInt(),
      satisfaction: json['satisfaction'] as bool? ?? false,
      wouldRecommend: json['wouldRecommend'] as bool? ?? false,
      comment: json['comment'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

/// The signed-in customer's own review of one accommodation, as returned by
/// `GET /api/Feedback/Mine/{accommodationId}`. Unlike [AccommodationReview]
/// this one carries no display name -- it is always the reader's own.
class MyReview {
  final String id;
  final String accommodationId;
  final int rating;
  final bool satisfaction;
  final bool wouldRecommend;
  final String comment;
  final String? imageUrl;

  MyReview({
    required this.id,
    required this.accommodationId,
    required this.rating,
    required this.satisfaction,
    required this.wouldRecommend,
    required this.comment,
    this.imageUrl,
  });

  factory MyReview.fromJson(Map<String, dynamic> json) {
    return MyReview(
      id: json['id'] as String,
      accommodationId: json['accommodationId'] as String,
      rating: (json['rating'] as num).toInt(),
      satisfaction: json['satisfaction'] as bool? ?? false,
      wouldRecommend: json['wouldRecommend'] as bool? ?? false,
      comment: json['comment'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
