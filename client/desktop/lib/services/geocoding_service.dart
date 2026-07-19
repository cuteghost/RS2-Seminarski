import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:ebooking_desktop/config/config.dart' as config;

class GeocodeResult {
  final String displayName;
  final double latitude;
  final double longitude;

  const GeocodeResult({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });
}

class GeocodingException implements Exception {
  final String message;

  const GeocodingException(this.message);

  @override
  String toString() => message;
}

/// Pretvara adresu u koordinate preko Nominatima (OpenStreetMap).
///
/// Nominatim ne traži ključ, pa u repou nema tajne koju bi trebalo skrivati;
/// traži samo `User-Agent` koji identifikuje aplikaciju. Adresa servisa se
/// ipak čita iz okruženja, da se instalacija može preusmjeriti na vlastiti
/// primjerak bez izmjene koda.
class GeocodingService {
  static const _userAgent = 'eBookingDesktop/1.0 (RS2 seminarski)';

  Future<List<GeocodeResult>> search(String query) async {
    final text = query.trim();
    if (text.length < 3) {
      throw const GeocodingException(
          'Enter at least three characters of the address before searching.');
    }

    final uri = Uri.parse('${config.AppConfig.geocoderUrl}/search').replace(
      queryParameters: {
        'q': text,
        'format': 'jsonv2',
        'limit': '5',
        'addressdetails': '0',
      },
    );

    final http.Response response;
    try {
      response = await http
          .get(uri, headers: {'User-Agent': _userAgent, 'Accept': 'application/json'})
          .timeout(const Duration(seconds: 12));
    } catch (_) {
      throw const GeocodingException(
          'The address search service is unavailable. Check your internet connection '
          'and try again.');
    }

    if (response.statusCode != 200) {
      throw GeocodingException(
          'The address search service returned an error (HTTP ${response.statusCode}).');
    }

    final decoded = json.decode(response.body);
    if (decoded is! List) {
      throw const GeocodingException(
          'The address search service returned an unexpected response.');
    }

    final results = <GeocodeResult>[];
    for (final item in decoded) {
      if (item is! Map<String, dynamic>) continue;

      final lat = double.tryParse(item['lat']?.toString() ?? '');
      final lon = double.tryParse(item['lon']?.toString() ?? '');
      if (lat == null || lon == null) continue;

      results.add(GeocodeResult(
        displayName: item['display_name']?.toString() ?? text,
        latitude: lat,
        longitude: lon,
      ));
    }

    return results;
  }
}
