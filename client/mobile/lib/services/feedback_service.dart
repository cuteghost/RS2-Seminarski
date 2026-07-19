import 'package:ebooking/config/app_constants.dart';
import 'package:ebooking/models/feedback_model.dart';
import 'package:ebooking/services/api_client.dart';

class FeedbackService {
  FeedbackService({required this._apiClient});

  final ApiClient _apiClient;

  Future<Paged<AccommodationReview>> fetchForAccommodation(
    String accommodationId, {
    int page = ApiPagination.firstPage,
  }) {
    return _apiClient.getPaged<AccommodationReview>(
      '/api/Feedback/ByAccommodation/$accommodationId',
      query: const <String, String>{'onlyWithComment': 'true'},
      parseItem: AccommodationReview.fromJson,
      page: page,
    );
  }

  /// The review this customer left for one accommodation. `ByAccommodation`
  /// cannot answer this: it pages through everyone's reviews and drops the
  /// ones without a comment.
  Future<MyReview> fetchMine(String accommodationId) {
    return _apiClient.get<MyReview>(
      '/api/Feedback/Mine/$accommodationId',
      parse: (data) => MyReview.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<String> makeFeedback(FeedbackPOST feedback) async {
    final result = await _apiClient.postWithMessage<void>(
      '/api/Feedback',
      body: feedback.toJson(),
      parse: (_) {},
    );
    return result.message;
  }
}
