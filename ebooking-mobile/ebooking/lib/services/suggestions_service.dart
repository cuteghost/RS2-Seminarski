import 'dart:convert';
import 'package:ebooking/models/accomodation_model.dart';
import 'package:http/http.dart' as http;
import 'package:ebooking/config/config.dart' as config;

class SuggestionsService {

  Future<List<AccommodationGET>> fetchRecommendations(String customerId) async {
    final response = await http.get(Uri.parse('${config.AppConfig.baseUrl}/api/Recommendation/suggestions/$customerId'));
    print('Recommendations Response: ${response.body}');
    if (response.statusCode == 200) {
      return List<AccommodationGET>.from(json.decode(response.body).map((x) => AccommodationGET.fromJson(x)));
    } else {
      throw Exception('Failed to load recommendations');
    }
  }
}
