import 'package:ebooking/config/app_constants.dart';
import 'package:ebooking/models/accommodation_model.dart';
import 'package:ebooking/services/api_client.dart';

class SearchCriteria {
  final double priceFrom;
  final double priceTo;
  final String city;
  final DateTime checkIn;
  final DateTime checkOut;
  final String? accommodationTypeId;
  final double? minReviewScore;
  final Set<String> amenityIds;

  const SearchCriteria({
    required this.priceFrom,
    required this.priceTo,
    required this.city,
    required this.checkIn,
    required this.checkOut,
    this.accommodationTypeId,
    this.minReviewScore,
    this.amenityIds = const <String>{},
  });

  SearchCriteria copyWith({
    double? priceFrom,
    double? priceTo,
    String? accommodationTypeId,
    double? minReviewScore,
    Set<String>? amenityIds,
  }) {
    return SearchCriteria(
      priceFrom: priceFrom ?? this.priceFrom,
      priceTo: priceTo ?? this.priceTo,
      city: city,
      checkIn: checkIn,
      checkOut: checkOut,
      accommodationTypeId: accommodationTypeId ?? this.accommodationTypeId,
      minReviewScore: minReviewScore ?? this.minReviewScore,
      amenityIds: amenityIds ?? this.amenityIds,
    );
  }
}

class SearchService {
  SearchService({required this._apiClient});

  final ApiClient _apiClient;

  Future<Paged<AccommodationGET>> search(
    SearchCriteria criteria, {
    int page = ApiPagination.firstPage,
  }) {
    return _apiClient.getPaged<AccommodationGET>(
      '/api/Search',
      query: <String, String>{
        'priceFrom': '${criteria.priceFrom}',
        'priceTo': '${criteria.priceTo}',
        'city': criteria.city,
        'checkIn': criteria.checkIn.toIso8601String(),
        'checkOut': criteria.checkOut.toIso8601String(),
        if (criteria.accommodationTypeId != null)
          'accommodationTypeId': criteria.accommodationTypeId!,
        if (criteria.minReviewScore != null && criteria.minReviewScore! > 0)
          'minReviewScore': '${criteria.minReviewScore}',
        if (criteria.amenityIds.isNotEmpty)
          'amenityIds': criteria.amenityIds.join(','),
      },
      parseItem: AccommodationGET.fromJson,
      page: page,
    );
  }
}
