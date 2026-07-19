class AccommodationReview {
  final String id;
  final String accommodationId;
  final String customerDisplayName;
  final int rating;
  final bool satisfaction;
  final bool wouldRecommend;
  final String comment;

  const AccommodationReview({
    required this.id,
    required this.accommodationId,
    required this.customerDisplayName,
    required this.rating,
    required this.satisfaction,
    required this.wouldRecommend,
    required this.comment,
  });

  factory AccommodationReview.fromJson(Map<String, dynamic> json) {
    return AccommodationReview(
      id: json['id']?.toString() ?? '',
      accommodationId: json['accommodationId']?.toString() ?? '',
      customerDisplayName:
          json['customerDisplayName']?.toString() ?? 'Unknown user',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      satisfaction: json['satisfaction'] == true,
      wouldRecommend: json['wouldRecommend'] == true,
      comment: json['comment']?.toString() ?? '',
    );
  }
}
