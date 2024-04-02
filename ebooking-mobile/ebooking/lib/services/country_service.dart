import 'package:http/http.dart' as http;
import 'package:ebooking/config/config.dart';


class CountryService {
  Future<List<dynamic>> getCountries() async {
    final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/Country/GetCountries'));
    if (response.statusCode == 200) {
      // Parse the JSON data and return
      // Assuming you get a JSON array as a response
      return []; // Replace with actual JSON parsing
    } else {
      throw Exception('Failed to load countries');
    }
  }
}
