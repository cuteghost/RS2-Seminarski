class FeedbackPOST {
  final int rating;
  final bool satisfaction;
  final bool wouldRecommend;
  final String accommodationId;
  final String? comment;

  
  FeedbackPOST({
    required this.rating,
    required this.satisfaction,
    required this.wouldRecommend,
    required this.accommodationId,
    this.comment
  });
  
  Map<String, dynamic> toJson() {
    return {
      'Rating': rating,
      'Satisfaction': satisfaction,
      'WouldRecommend': wouldRecommend,
      'AccommodationId': accommodationId,
      'Comment': comment
    };
  }
}