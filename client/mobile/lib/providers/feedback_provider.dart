import 'package:ebooking/services/feedback_service.dart';
import 'package:ebooking/models/feedback_model.dart';
import 'package:flutter/material.dart';

class FeedbackProvider with ChangeNotifier {
  final FeedbackService _feedbackService;

  FeedbackProvider({required this._feedbackService});

  Future<void> makeFeedback(FeedbackPOST feedback) async {
    await _feedbackService.makeFeedback(feedback);
    notifyListeners();
  }
}
