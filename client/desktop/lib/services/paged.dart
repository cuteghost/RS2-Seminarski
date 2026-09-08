import 'package:http/http.dart' as http;

import 'package:ebooking_desktop/services/api_response_handler.dart';

class PagedResult<T> {
  final List<T> items;
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  const PagedResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;
}

class Paged {
  Paged._();

  static const int maxPageSize = 100;

  static const int pageLimit = 20;

  static PagedResult<T> read<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final body = ApiResponseHandler.decode(response);

    if (body is List) {
      final items =
          body.whereType<Map<String, dynamic>>().map(fromJson).toList();
      return PagedResult<T>(
        items: items,
        page: 1,
        pageSize: items.length,
        totalCount: items.length,
        totalPages: 1,
      );
    }

    if (body is! Map<String, dynamic>) {
      throw const ApiException(500, 'Unexpected response format from the server.');
    }

    final data = body['data'];
    final items = data is List
        ? data.whereType<Map<String, dynamic>>().map(fromJson).toList()
        : <T>[];

    return PagedResult<T>(
      items: items,
      page: (body['page'] as num?)?.toInt() ?? 1,
      pageSize: (body['pageSize'] as num?)?.toInt() ?? items.length,
      totalCount: (body['totalCount'] as num?)?.toInt() ?? items.length,
      totalPages: (body['totalPages'] as num?)?.toInt() ?? 1,
    );
  }

  static Future<List<T>> all<T>(
    Future<PagedResult<T>> Function(int page, int pageSize) fetch,
  ) async {
    final collected = <T>[];

    var page = 1;
    var pages = 1;

    while (page <= pages && page <= pageLimit) {
      final result = await fetch(page, maxPageSize);
      collected.addAll(result.items);

      pages = result.totalPages;
      if (result.items.isEmpty) break;

      page++;
    }

    return collected;
  }
}
