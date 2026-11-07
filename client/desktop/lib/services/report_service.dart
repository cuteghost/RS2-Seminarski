import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:ebooking_desktop/config/config.dart' as config;
import 'package:ebooking_desktop/models/report_model.dart';
import 'package:ebooking_desktop/services/api_response_handler.dart';
import 'package:ebooking_desktop/services/auth_service.dart';

class ReportService {
  final SecureStorage _secureStorage;

  ReportService({required SecureStorage secureStorage})
      : _secureStorage = secureStorage;

  static final _date = DateFormat('yyyy-MM-dd');

  /// `GET /api/Report/Overview` — metrike i grafovi se računaju na serveru.
  Future<ReportOverview> overview({
    required DateTime from,
    required DateTime to,
    required ReportInterval interval,
    int top = 10,
  }) async {
    final token = await _secureStorage.getToken();
    final uri = Uri.parse('${config.AppConfig.baseUrl}/api/Report/Overview')
        .replace(queryParameters: {
      'from': _date.format(from),
      'to': _date.format(to),
      'interval': interval.apiValue,
      'top': '$top',
    });
    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });
    final data = ApiResponseHandler.unwrap(response);
    if (data is! Map) {
      throw const FormatException('The report response is empty.');
    }
    return ReportOverview.fromJson(
        data.map((k, v) => MapEntry(k.toString(), v)));
  }
}
