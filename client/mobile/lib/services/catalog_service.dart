import 'package:ebooking/models/catalog_model.dart';
import 'package:ebooking/services/api_client.dart';

class CatalogService {
  CatalogService({required this._apiClient});

  final ApiClient _apiClient;

  Future<List<AccommodationType>> getTypes() {
    return _apiClient.getAllPages<AccommodationType>(
      '/api/AccommodationType/GetTypes',
      parseItem: AccommodationType.fromJson,
    );
  }

  Future<List<Amenity>> getAmenities() {
    return _apiClient.getAllPages<Amenity>(
      '/api/Amenity/GetAmenities',
      parseItem: Amenity.fromJson,
    );
  }
}
