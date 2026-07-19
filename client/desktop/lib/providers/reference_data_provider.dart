import 'package:flutter/foundation.dart';

import 'package:ebooking_desktop/models/accommodation_type.dart';
import 'package:ebooking_desktop/models/amenity.dart';
import 'package:ebooking_desktop/services/api_response_handler.dart';
import 'package:ebooking_desktop/services/reference_data_service.dart';

class ReferenceDataProvider with ChangeNotifier {
  final ReferenceDataService referenceDataService;

  ReferenceDataProvider({required this.referenceDataService});

  List<AccommodationType> _types = [];
  List<Amenity> _amenities = [];

  bool _isLoading = false;
  String? _error;

  String _typeQuery = '';
  String _amenityQuery = '';

  List<AccommodationType> get types => List.unmodifiable(_types);
  List<Amenity> get amenities => List.unmodifiable(_amenities);

  bool get isLoading => _isLoading;
  String? get error => _error;

  String get typeQuery => _typeQuery;
  String get amenityQuery => _amenityQuery;

  List<AccommodationType> get filteredTypes {
    final query = _typeQuery.trim().toLowerCase();
    if (query.isEmpty) return types;
    return _types
        .where((t) => t.name.toLowerCase().contains(query))
        .toList(growable: false);
  }

  List<Amenity> get filteredAmenities {
    final query = _amenityQuery.trim().toLowerCase();
    if (query.isEmpty) return amenities;
    return _amenities
        .where((a) =>
            a.name.toLowerCase().contains(query) ||
            a.code.toLowerCase().contains(query))
        .toList(growable: false);
  }

  Future<void> loadAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        referenceDataService.getTypes(),
        referenceDataService.getAmenities(),
      ]);
      _types = results[0] as List<AccommodationType>;
      _amenities = results[1] as List<Amenity>;
    } catch (e) {
      _error = ApiResponseHandler.describe(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reloadTypes() async {
    _types = await referenceDataService.getTypes();
    notifyListeners();
  }

  Future<void> reloadAmenities() async {
    _amenities = await referenceDataService.getAmenities();
    notifyListeners();
  }

  Future<String> addType({required String name, required int sortOrder}) async {
    final message =
        await referenceDataService.addType(name: name, sortOrder: sortOrder);
    await reloadTypes();
    return message;
  }

  Future<String> updateType({
    required String id,
    required String name,
    required int sortOrder,
  }) async {
    final message = await referenceDataService.updateType(
        id: id, name: name, sortOrder: sortOrder);
    await reloadTypes();
    return message;
  }

  Future<String> deleteType(String id) async {
    final message = await referenceDataService.deleteType(id);
    await reloadTypes();
    return message;
  }

  Future<String> addAmenity({
    required String code,
    required String name,
    required int sortOrder,
  }) async {
    final message = await referenceDataService.addAmenity(
        code: code, name: name, sortOrder: sortOrder);
    await reloadAmenities();
    return message;
  }

  Future<String> updateAmenity({
    required String id,
    required String code,
    required String name,
    required int sortOrder,
  }) async {
    final message = await referenceDataService.updateAmenity(
        id: id, code: code, name: name, sortOrder: sortOrder);
    await reloadAmenities();
    return message;
  }

  Future<String> deleteAmenity(String id) async {
    final message = await referenceDataService.deleteAmenity(id);
    await reloadAmenities();
    return message;
  }

  void setTypeQuery(String value) {
    _typeQuery = value;
    notifyListeners();
  }

  void setAmenityQuery(String value) {
    _amenityQuery = value;
    notifyListeners();
  }

  int get nextTypeSortOrder =>
      _types.isEmpty ? 1 : _types.map((t) => t.sortOrder).reduce(_max) + 1;

  int get nextAmenitySortOrder =>
      _amenities.isEmpty ? 1 : _amenities.map((a) => a.sortOrder).reduce(_max) + 1;

  static int _max(int a, int b) => a > b ? a : b;
}
