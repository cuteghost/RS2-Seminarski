import 'package:ebooking/services/feedback_service.dart';
import 'package:ebooking/models/feedback_model.dart';
import 'package:flutter/material.dart';

class FeedbackProvider with ChangeNotifier {
  final FeedbackService _feedbackService;

  FeedbackProvider({required this._feedbackService});

  final Map<String, List<AccommodationReview>> _reviews = {};
  final Map<String, int> _reviewsPage = {};
  final Map<String, int> _reviewsTotalPages = {};
  final Set<String> _loading = {};
  final Set<String> _loadingMore = {};

  List<AccommodationReview>? reviewsFor(String accommodationId) =>
      _reviews[accommodationId];

  bool isLoadingReviews(String accommodationId) =>
      _loading.contains(accommodationId);

  bool isLoadingMoreReviews(String accommodationId) =>
      _loadingMore.contains(accommodationId);

  bool hasMoreReviews(String accommodationId) =>
      (_reviewsPage[accommodationId] ?? 1) <
      (_reviewsTotalPages[accommodationId] ?? 1);

  Future<void> loadReviews(String accommodationId) async {
    if (_loading.contains(accommodationId)) return;
    _loading.add(accommodationId);
    try {
      final page = await _feedbackService.fetchForAccommodation(
        accommodationId,
      );
      _reviews[accommodationId] = page.items;
      _reviewsPage[accommodationId] = page.page;
      _reviewsTotalPages[accommodationId] = page.totalPages;
    } finally {
      _loading.remove(accommodationId);
      notifyListeners();
    }
  }

  Future<void> loadMoreReviews(String accommodationId) async {
    if (_loadingMore.contains(accommodationId) ||
        !hasMoreReviews(accommodationId)) {
      return;
    }
    _loadingMore.add(accommodationId);
    notifyListeners();
    try {
      final nextPage = (_reviewsPage[accommodationId] ?? 1) + 1;
      final page = await _feedbackService.fetchForAccommodation(
        accommodationId,
        page: nextPage,
      );
      _reviews[accommodationId] = [
        ...?_reviews[accommodationId],
        ...page.items,
      ];
      _reviewsPage[accommodationId] = page.page;
      _reviewsTotalPages[accommodationId] = page.totalPages;
    } finally {
      _loadingMore.remove(accommodationId);
      notifyListeners();
    }
  }

  Future<MyReview> myReview(String accommodationId) {
    return _feedbackService.fetchMine(accommodationId);
  }

  Future<String> makeFeedback(FeedbackPOST feedback) async {
    final message = await _feedbackService.makeFeedback(feedback);
    _reviews.remove(feedback.accommodationId);
    _reviewsPage.remove(feedback.accommodationId);
    _reviewsTotalPages.remove(feedback.accommodationId);
    notifyListeners();
    return message;
  }
}
