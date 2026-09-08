import 'package:ebooking/models/catalog_model.dart';
import 'package:ebooking/services/api_client.dart';
import 'package:ebooking/services/catalog_service.dart';
import 'package:flutter/material.dart';

class CatalogProvider with ChangeNotifier {
  CatalogProvider({required this._catalogService});

  final CatalogService _catalogService;

  List<AccommodationType> _types = [];
  List<Amenity> _amenities = [];
  String? _error;
  bool _loading = false;

  List<AccommodationType> get types => _types;
  List<Amenity> get amenities => _amenities;
  String? get error => _error;
  bool get isLoading => _loading;

  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final loaded = await Future.wait<dynamic>([
        _catalogService.getTypes(),
        _catalogService.getAmenities(),
      ]);
      _types = (loaded[0] as List<AccommodationType>)
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      _amenities = (loaded[1] as List<Amenity>)
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    } on ApiException catch (e) {
      _types = [];
      _amenities = [];
      _error = e.message;
    }

    _loading = false;
    notifyListeners();
  }
}
