import 'dart:convert';

import 'package:http/http.dart' as http;

/// Greška koja je stigla sa API-ja u standardizovanom obliku.
///
/// Backend `GlobalExceptionHandler` (API/Exceptions/GlobalExceptionHandler.cs)
/// za SVAKI neuhvaćeni izuzetak vraća `{ statusCode, message, details? }`.
/// `NotFoundException` -> 404, `BusinessException` -> 400, ostalo -> 500.
///
/// Upute Dodatak A.2: "_handleResponse ne smije prikrivati backend validacijske
/// poruke, već ih treba proslijediti korisniku." Zato ova klasa nosi `message`
/// tačno onako kako ga je server poslao — UI ga prikazuje doslovno.
class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  bool get isUnauthorized => statusCode == 401 || statusCode == 403;
  bool get isNotFound => statusCode == 404;

  @override
  String toString() => message;
}

/// Zajednička obrada HTTP odgovora za sve servise.
///
/// Prije je svaki servis imao svoj `throw Exception('Failed to load X')`, pa je
/// korisnik uvijek vidio generičku poruku umjesto onoga što je server rekao.
class ApiResponseHandler {
  ApiResponseHandler._();

  static bool _isSuccess(int code) => code >= 200 && code < 300;

  /// Vraća dekodirano tijelo ili baca [ApiException] sa serverskom porukom.
  static dynamic decode(http.Response response) {
    if (_isSuccess(response.statusCode)) {
      if (response.body.isEmpty) return null;
      try {
        return json.decode(response.body);
      } on FormatException {
        // Neki stariji endpointi vraćaju goli tekst (`Content("Ok")`).
        return response.body;
      }
    }
    throw ApiException(response.statusCode, extractMessage(response));
  }

  /// Odmotava `BaseResponse<T>` -> `data`.
  ///
  /// Golden-template endpointi (`/api/Country/*`) vraćaju `{ message, data }`.
  /// Endpointi koji još nisu refaktorisani vraćaju goli objekat/listu — zato
  /// se `data` uzima samo ako stvarno postoji, inače se vraća tijelo kakvo jest.
  static dynamic unwrap(http.Response response) {
    final body = decode(response);
    if (body is Map<String, dynamic> && body.containsKey('data')) {
      return body['data'];
    }
    return body;
  }

  /// Odmotava odgovor u listu mapa, bez obzira da li je omotan ili ne.
  static List<Map<String, dynamic>> unwrapList(http.Response response) {
    final data = unwrap(response);
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }
    return const [];
  }

  /// Poruka o uspjehu koju je server poslao (`BaseResponse.Message`),
  /// ili `fallback` ako endpoint ne koristi omotač.
  ///
  /// Upute 4: "Nakon uspješnog dodavanja zapisa korisniku treba prikazati
  /// adekvatnu poruku o uspjehu, a ne generičku poruku poput 'Success'."
  static String successMessage(http.Response response, String fallback) {
    try {
      final body = decode(response);
      if (body is Map<String, dynamic>) {
        final message = body['message'];
        if (message is String && message.trim().isNotEmpty) return message;
      }
    } on ApiException {
      rethrow;
    } catch (_) {
      // Tijelo nije JSON — koristimo fallback.
    }
    return fallback;
  }

  /// Izvlači poruku greške iz tijela odgovora.
  static String extractMessage(http.Response response) {
    if (response.body.isNotEmpty) {
      try {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          final message = decoded['message'] ?? decoded['Message'];
          if (message is String && message.trim().isNotEmpty) return message;

          // ASP.NET ProblemDetails za model-validation greške.
          final errors = decoded['errors'] ?? decoded['Errors'];
          if (errors is Map<String, dynamic> && errors.isNotEmpty) {
            final first = errors.values.first;
            if (first is List && first.isNotEmpty) return first.first.toString();
          }

          final title = decoded['title'] ?? decoded['Title'];
          if (title is String && title.trim().isNotEmpty) return title;
        }
        if (decoded is String && decoded.trim().isNotEmpty) return decoded;
      } catch (_) {
        // Nije JSON — pada na default poruke ispod.
      }
    }

    switch (response.statusCode) {
      case 400:
        return 'Zahtjev nije ispravan. Provjerite unesene podatke.';
      case 401:
        return 'Sesija je istekla. Prijavite se ponovo.';
      case 403:
        return 'Nemate ovlaštenje za ovu akciju.';
      case 404:
        return 'Traženi zapis nije pronađen.';
      case 409:
        return 'Zapis sa istim podacima već postoji.';
      case 500:
        return 'Došlo je do greške na serveru. Pokušajte ponovo.';
      default:
        return 'Neočekivan odgovor servera (HTTP ${response.statusCode}).';
    }
  }

  /// Pretvara bilo koji izuzetak u poruku koju je sigurno pokazati korisniku.
  /// `SocketException` i sl. ne smiju procuriti u UI kao stack trace.
  static String describe(Object error) {
    if (error is ApiException) return error.message;
    final text = error.toString();
    if (text.contains('SocketException') ||
        text.contains('Connection refused') ||
        text.contains('Failed host lookup')) {
      return 'Nije moguće uspostaviti vezu sa serverom. '
          'Provjerite da li API radi i da li je API_BASE_URL ispravan.';
    }
    if (text.contains('TimeoutException')) {
      return 'Server nije odgovorio na vrijeme. Pokušajte ponovo.';
    }
    return 'Došlo je do neočekivane greške. Pokušajte ponovo.';
  }
}
