import 'package:ebooking/config/app_constants.dart';
import 'package:ebooking/models/notification_model.dart';
import 'package:ebooking/services/api_client.dart';

class NotificationService {
  NotificationService({required this._apiClient});

  final ApiClient _apiClient;

  Future<Paged<AppNotification>> fetch({
    int page = ApiPagination.firstPage,
    bool unreadOnly = false,
  }) {
    return _apiClient.getPaged<AppNotification>(
      '/api/Notification',
      query: <String, String>{'unreadOnly': '$unreadOnly'},
      parseItem: AppNotification.fromJson,
      page: page,
    );
  }

  Future<int> unreadCount() {
    return _apiClient.get<int>(
      '/api/Notification/UnreadCount',
      parse: (data) => (data as num).toInt(),
    );
  }

  Future<void> markRead(String id) {
    return _apiClient.patch<void>(
      '/api/Notification/Read/$id',
      parse: (_) {},
    );
  }

  Future<void> markAllRead() {
    return _apiClient.patch<void>(
      '/api/Notification/ReadAll',
      parse: (_) {},
    );
  }
}
