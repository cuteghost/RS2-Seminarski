import 'package:ebooking/config/app_constants.dart';
import 'package:ebooking/models/accommodation_model.dart';
import 'package:ebooking/services/api_client.dart';

class SuggestionsService {
  SuggestionsService({required this._apiClient});

  final ApiClient _apiClient;

  /// The customer comes from the token now. The route used to carry an id
  /// (`/suggestions/{customerId}`) and had no authentication at all, so anyone
  /// could read anyone else's recommendations. It also sent no bearer token —
  /// this service was the only one with no `Authorization` header.
  Future<List<AccommodationGET>> fetchRecommendations() async {
    final page = await _apiClient.getPaged<AccommodationGET>(
      '/api/Recommendation/suggestions',
      parseItem: AccommodationGET.fromJson,
      page: ApiPagination.firstPage,
      pageSize: SuggestionLimits.topCount,
    );
    return page.items;
  }
}
