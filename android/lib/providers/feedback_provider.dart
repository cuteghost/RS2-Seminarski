import 'package:ebooking/services/feedback_service.dart';
import 'package:ebooking/models/feedback_model.dart';
import 'package:flutter/material.dart';

class FeedbackProvider with ChangeNotifier
{
  final FeedbackService _feedbackService;
  
  FeedbackProvider({required FeedbackService feedbackService}) : _feedbackService = feedbackService;

  Future<void> makeFeedback(FeedbackPOST feedback) async {
    await _feedbackService.makeFeedback(feedback);
    notifyListeners();
  }
}