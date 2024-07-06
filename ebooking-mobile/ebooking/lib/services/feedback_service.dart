import 'dart:convert';

import 'package:ebooking/models/feedback_model.dart';
import 'package:ebooking/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:ebooking/config/config.dart';


class FeedbackService {
  final SecureStorage _secureStorage;
  
  FeedbackService({required SecureStorage secureStorage}) : _secureStorage = secureStorage;
  
  Future<void> makeFeedback(FeedbackPOST feedback) async {
    final token = await _secureStorage.getToken();
    final response = await http.post(Uri.parse('${AppConfig.baseUrl}/api/Feedback'), 
                    headers: {
                      'Authorization': 'Bearer $token',
                      'Content-Type': 'application/json'
                      },
                      body: json.encode(feedback.toJson()));
    print(response.statusCode);
    if (response.statusCode != 200) {
      throw Exception('Failed to make feedback');
    }
    else {
      return;
    }
  }
}