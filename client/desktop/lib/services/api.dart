import 'dart:convert';

import 'package:http/http.dart' as http;

/// Greška vraćena sa API-ja, već prevedena u poruku koju je bezbjedno
/// prikazati korisniku.
///
/// Backend `GlobalExceptionHandler` vraća `{ statusCode, message, details? }`.
/// `details` (stack trace) se u produkciji ne šalje, a i kad se pošalje —
/// NIKAD ga ne prikazujemo korisniku (Upute 3.4: klijentu se ne izlažu
/// stack trace-ovi ni infrastrukturni detalji).
class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;

  @override
  String toString() => message;
}

/// Rezultat operacije koja mijenja podatke — nosi poruku sa servera
/// da UI može prikazati baš ono što je backend rekao, umjesto generičkog
/// "Success" (Upute 4).
class MutationResult {
  final bool success;
  final String message;

  const MutationResult({required this.success, required this.message});
}

/// Zajednička obrada HTTP odgovora za sve servise.
///
/// Upute Dodatak A.2: "_handleResponse ne smije prikrivati backend
/// validacijske poruke, već ih treba proslijediti korisniku." Zato se
/// `message` iz tijela odgovora čita i propušta dalje, umjesto ranijeg
/// `throw Exception('Failed to load X')`.
class ApiResponse {
  ApiResponse._();

  /// Odmotava USPJEŠAN odgovor. Podržava tri oblika, jer backend nije
  /// jednoobrazan dok golden-template refaktor ne pređe sve entitete:
  ///   * `BaseResponse<T>`  -> `{ message, data }`
  ///   * `PagedResponse<T>` -> `{ message, data, page, pageSize, totalCount, totalPages }`
  ///   * goli JSON (stari kontroleri, npr. `/api/Administrator/*`)
  static dynamic unwrap(http.Response response) {
    _throwIfError(response);

    if (response.body.isEmpty) return null;

    final decoded = _decodeBody(response.body);
    if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
      return decoded['data'];
    }
    return decoded;
  }

  /// Odmotava listu. Vraća praznu listu umjesto `null` da UI ne mora
  /// svuda provjeravati.
  static List<Map<String, dynamic>> unwrapList(http.Response response) {
    final data = unwrap(response);
    if (data is! List) return const [];
    return data.whereType<Map<String, dynamic>>().toList();
  }

  static Map<String, dynamic>? unwrapObject(http.Response response) {
    final data = unwrap(response);
    return data is Map<String, dynamic> ? data : null;
  }

  /// Poruka o uspjehu koju je server poslao (`BaseResponse.Message`),
  /// ili `fallback` ako je kontroler stari i ne šalje omotač.
  /// Upute 4: prikazati smislenu poruku, ne generičko "Success".
  static String successMessage(http.Response response, String fallback) {
    if (response.body.isEmpty) return fallback;
    try {
      final decoded = _decodeBody(response.body);
      if (decoded is Map<String, dynamic>) {
        final msg = decoded['message'];
        if (msg is String && msg.trim().isNotEmpty) return msg;
      }
    } catch (_) {
      // Nije JSON (stari `Content("Ok")`) — koristi fallback.
    }
    return fallback;
  }

  static dynamic _decodeBody(String body) {
    try {
      return json.decode(body);
    } on FormatException {
      // Stari kontroleri vraćaju `Content("Ok")` — goli tekst.
      return body;
    }
  }

  static void _throwIfError(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    throw ApiException(
      response.statusCode,
      _extractMessage(response),
    );
  }

  static String _extractMessage(http.Response response) {
    if (response.body.isNotEmpty) {
      try {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          final msg = decoded['message'] ?? decoded['Message'] ?? decoded['title'];
          if (msg is String && msg.trim().isNotEmpty) return msg;

          // ASP.NET ModelState greške: { errors: { Field: ["poruka"] } }
          final errors = decoded['errors'];
          if (errors is Map) {
            final flattened = errors.values
                .whereType<List>()
                .expand((e) => e)
                .whereType<String>()
                .toList();
            if (flattened.isNotEmpty) return flattened.join('\n');
          }
        }
      } catch (_) {
        // Tijelo nije JSON — pada na generičku poruku ispod.
      }
    }
    return _defaultMessage(response.statusCode);
  }

  static String _defaultMessage(int status) {
    switch (status) {
      case 400:
        return 'Zahtjev nije ispravan. Provjerite unesene podatke.';
      case 401:
        return 'Sesija je istekla. Prijavite se ponovo.';
      case 403:
        return 'Nemate ovlaštenje za ovu akciju.';
      case 404:
        return 'Traženi zapis nije pronađen.';
      case 409:
        return 'Zapis sa tim podacima već postoji.';
      case 500:
        return 'Došlo je do greške na serveru. Pokušajte ponovo kasnije.';
      case 503:
        return 'Servis trenutno nije dostupan. Provjerite da li je API pokrenut.';
      default:
        return 'Neočekivana greška (HTTP $status).';
    }
  }
}

/// Prevodi mrežne izuzetke u poruku razumljivu korisniku.
/// Bez ovoga korisnik pri ugašenom Docker-u vidi
/// "SocketException: Connection refused (OS Error: …, errno = 111)".
String describeNetworkError(Object error) {
  if (error is ApiException) return error.message;
  final text = error.toString();
  if (text.contains('SocketException') ||
      text.contains('Connection refused') ||
      text.contains('Connection closed')) {
    return 'Nije moguće uspostaviti vezu sa API servisom. '
        'Provjerite da li su Docker kontejneri pokrenuti.';
  }
  if (text.contains('TimeoutException')) {
    return 'API servis ne odgovara. Pokušajte ponovo.';
  }
  return 'Došlo je do neočekivane greške. Pokušajte ponovo.';
}
