import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ebooking/config/app_constants.dart';
import 'package:ebooking/config/config.dart';
import 'package:ebooking/services/secure_storage.dart';
import 'package:http/http.dart' as http;

/// An error the API reported in its documented error shape,
/// `{ statusCode, message, details }`.
///
/// [message] is the server's own text and is meant to reach the user word for
/// word — a service must not replace it with a sentence of its own.
class ApiException implements Exception {
  ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => message;
}

/// Raised for `401`. The stored token has already been deleted and the
/// redirect to the login screen has already been requested when this is thrown.
///
/// `[Authorize]` rejects the request inside the ASP.NET authentication
/// middleware, before the exception handler runs, so the body is empty and is
/// never parsed as JSON.
class UnauthorizedException extends ApiException {
  UnauthorizedException()
    : super(401, 'Your session has expired. Please sign in again.');
}

/// Raised for `403`: the token is valid but the role is wrong. Empty body for
/// the same reason as [UnauthorizedException].
class ForbiddenException extends ApiException {
  ForbiddenException() : super(403, 'Your account is not allowed to do that.');
}

/// Raised when the request never reached the API — no network, wrong host, or
/// the container is not up yet.
class NetworkException extends ApiException {
  NetworkException()
    : super(
        0,
        'Could not reach the server. Check your connection and try again.',
      );
}

/// One page of a list endpoint: the whole
/// `{ message, data, page, pageSize, totalCount, totalPages }` envelope.
class Paged<T> {
  const Paged({
    required this.items,
    required this.message,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });

  final List<T> items;
  final String message;
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  bool get hasMore => page < totalPages;
}

/// Everything every service needs in one place: the bearer token, the
/// `{ message, data }` envelope, pagination, and the single reaction to a
/// `401`.
///
/// `location_service.dart` was the only service already reading
/// `decoded['data']`; this generalises that one case instead of leaving each
/// service to invent its own shape.
class ApiClient {
  /// [httpClient] exists so a test can hand in a stub; the app leaves it out.
  ApiClient({required this._secureStorage, http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  final SecureStorage _secureStorage;
  final http.Client _http;

  /// Called once the token has been cleared because the API answered `401`.
  /// `main.dart` points this at the navigator, so an expired token lands the
  /// user on the login screen instead of on a screen full of failed requests.
  void Function()? onUnauthorized;

  Future<T> get<T>(
    String path, {
    Map<String, String>? query,
    required T Function(dynamic data) parse,
    bool authenticated = true,
    bool unauthorizedIsExpiredSession = true,
  }) async {
    final envelope = await _envelope(
      () => _send('GET', path, query: query, authenticated: authenticated),
      unauthorizedIsExpiredSession: unauthorizedIsExpiredSession,
    );
    return parse(envelope['data']);
  }

  Future<T> post<T>(
    String path, {
    Object? body,
    Map<String, String>? query,
    required T Function(dynamic data) parse,
    bool authenticated = true,
    bool unauthorizedIsExpiredSession = true,
  }) async {
    final envelope = await _envelope(
      () => _send(
        'POST',
        path,
        query: query,
        body: body,
        authenticated: authenticated,
      ),
      unauthorizedIsExpiredSession: unauthorizedIsExpiredSession,
    );
    return parse(envelope['data']);
  }

  Future<({T data, String message})> postWithMessage<T>(
    String path, {
    Object? body,
    Map<String, String>? query,
    required T Function(dynamic data) parse,
    bool authenticated = true,
    bool unauthorizedIsExpiredSession = true,
  }) async {
    final envelope = await _envelope(
      () => _send(
        'POST',
        path,
        query: query,
        body: body,
        authenticated: authenticated,
      ),
      unauthorizedIsExpiredSession: unauthorizedIsExpiredSession,
    );
    return (
      data: parse(envelope['data']),
      message: envelope['message'] as String? ?? '',
    );
  }

  Future<T> patch<T>(
    String path, {
    Object? body,
    Map<String, String>? query,
    required T Function(dynamic data) parse,
  }) async {
    final envelope = await _envelope(
      () => _send('PATCH', path, query: query, body: body),
    );
    return parse(envelope['data']);
  }

  Future<void> delete(String path, {Map<String, String>? query}) async {
    await _envelope(() => _send('DELETE', path, query: query));
  }

  Future<Uint8List> getBytes(String path) async {
    final http.Response response;
    try {
      response = await _send('GET', path);
    } on http.ClientException {
      throw NetworkException();
    } on SocketException {
      throw NetworkException();
    }

    if (response.statusCode == 401) {
      await _secureStorage.deleteToken();
      onUnauthorized?.call();
      throw UnauthorizedException();
    }
    if (response.statusCode == 403) {
      throw ForbiddenException();
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.bodyBytes;
    }
    throw ApiException(
      response.statusCode,
      _messageFrom(_decode(response), response),
    );
  }

  /// One page of a list endpoint. `page` and `pageSize` are clamped by the
  /// server rather than rejected, so a bad value never turns into a `400`.
  Future<Paged<T>> getPaged<T>(
    String path, {
    Map<String, String>? query,
    required T Function(Map<String, dynamic> json) parseItem,
    int page = ApiPagination.firstPage,
    int pageSize = ApiPagination.defaultPageSize,
  }) async {
    final envelope = await _envelope(
      () => _send(
        'GET',
        path,
        query: <String, String>{
          ...?query,
          'page': '$page',
          'pageSize': '$pageSize',
        },
      ),
    );
    return _pagedFrom(envelope, parseItem);
  }

  /// Walks every page of a list endpoint and returns the whole set.
  ///
  /// For the screens that show a complete list with no paging control of their
  /// own — country and city dropdowns, a partner's own listings, a customer's
  /// trips. Without this they would silently show the first ten rows and look
  /// as if the rest did not exist.
  Future<List<T>> getAllPages<T>(
    String path, {
    Map<String, String>? query,
    required T Function(Map<String, dynamic> json) parseItem,
    int pageSize = ApiPagination.maxPageSize,
  }) async {
    final first = await getPaged<T>(
      path,
      query: query,
      parseItem: parseItem,
      pageSize: pageSize,
    );
    final items = <T>[...first.items];
    for (var page = first.page + 1; page <= first.totalPages; page++) {
      final next = await getPaged<T>(
        path,
        query: query,
        parseItem: parseItem,
        page: page,
        pageSize: pageSize,
      );
      if (next.items.isEmpty) break;
      items.addAll(next.items);
    }
    return items;
  }

  Paged<T> _pagedFrom<T>(
    Map<String, dynamic> envelope,
    T Function(Map<String, dynamic> json) parseItem,
  ) {
    final data = envelope['data'];
    final items = data is List
        ? data
              .whereType<Map<String, dynamic>>()
              .map(parseItem)
              .toList(growable: false)
        : <T>[];
    final page = _asInt(envelope['page'], ApiPagination.firstPage);
    return Paged<T>(
      items: items,
      message: envelope['message'] as String? ?? '',
      page: page,
      pageSize: _asInt(envelope['pageSize'], items.length),
      totalCount: _asInt(envelope['totalCount'], items.length),
      // An endpoint that omits totalPages still has to read as one full page,
      // otherwise getAllPages would stop before it returned anything.
      totalPages: _asInt(envelope['totalPages'], page),
    );
  }

  static int _asInt(Object? value, int fallback) =>
      value is num ? value.toInt() : fallback;

  Future<http.Response> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
    bool authenticated = true,
  }) async {
    final uri = Uri.parse(
      '${AppConfig.baseUrl}$path',
    ).replace(queryParameters: query == null || query.isEmpty ? null : query);

    final headers = <String, String>{'Accept': 'application/json'};
    if (body != null) headers['Content-Type'] = 'application/json';
    if (authenticated) {
      headers['Authorization'] = 'Bearer ${await _secureStorage.getToken()}';
    }
    final encoded = body == null ? null : json.encode(body);

    switch (method) {
      case 'POST':
        return _http.post(uri, headers: headers, body: encoded);
      case 'PATCH':
        return _http.patch(uri, headers: headers, body: encoded);
      case 'DELETE':
        return _http.delete(uri, headers: headers, body: encoded);
      default:
        return _http.get(uri, headers: headers);
    }
  }

  /// Turns a response into the decoded envelope, or throws the error the
  /// caller should show.
  ///
  /// [unauthorizedIsExpiredSession] is false for the sign-in endpoints: there a
  /// `401` means the password was wrong and does carry a body, so it must not
  /// clear the token and bounce the user to a login screen they are already on.
  Future<Map<String, dynamic>> _envelope(
    Future<http.Response> Function() send, {
    bool unauthorizedIsExpiredSession = true,
  }) async {
    // Only the two transport failures become a NetworkException. Anything else
    // — a body that cannot be encoded, say — is a bug in the caller and is left
    // to travel rather than dressed up as a connection problem.
    final http.Response response;
    try {
      response = await send();
    } on http.ClientException {
      throw NetworkException();
    } on SocketException {
      throw NetworkException();
    }

    if (response.statusCode == 401 && unauthorizedIsExpiredSession) {
      await _secureStorage.deleteToken();
      onUnauthorized?.call();
      throw UnauthorizedException();
    }
    if (response.statusCode == 403) {
      throw ForbiddenException();
    }

    final decoded = _decode(response);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }
    throw ApiException(response.statusCode, _messageFrom(decoded, response));
  }

  /// The contract's error shape is `{ statusCode, message, details }`, but a
  /// request that fails model binding never reaches the exception handler and
  /// comes back as ASP.NET's ProblemDetails instead — `title` plus an `errors`
  /// map. Both are read, so a rejected form says what was wrong with it rather
  /// than only which status code came back.
  String _messageFrom(Map<String, dynamic> decoded, http.Response response) {
    final message = decoded['message'];
    if (message is String && message.isNotEmpty) return message;

    final errors = decoded['errors'];
    if (errors is Map<String, dynamic>) {
      final first = errors.values
          .whereType<List<dynamic>>()
          .expand((list) => list)
          .whereType<String>()
          .firstWhere((text) => text.isNotEmpty, orElse: () => '');
      if (first.isNotEmpty) return first;
    }

    final title = decoded['title'];
    if (title is String && title.isNotEmpty) return title;

    return 'The server rejected the request (${response.statusCode}).';
  }

  /// Decodes from the raw bytes instead of `response.body`: without a charset
  /// on the content type the http package falls back to latin1, which mangles
  /// every diacritic in a server message.
  Map<String, dynamic> _decode(http.Response response) {
    if (response.bodyBytes.isEmpty) return const <String, dynamic>{};
    try {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) return decoded;
      return <String, dynamic>{'data': decoded};
    } on FormatException {
      return const <String, dynamic>{};
    }
  }
}
