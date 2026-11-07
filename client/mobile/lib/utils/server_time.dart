/// The server stores `DateTime.UtcNow` and serialises it without an offset,
/// so a bare timestamp is UTC and has to be marked as such before `toLocal()`
/// (otherwise Dart reads it as local time and the clock is off by the offset).
DateTime parseServerUtc(String raw) {
  final hasOffset = RegExp(r'(Z|[+-]\d{2}:?\d{2})$').hasMatch(raw);
  return DateTime.parse(hasOffset ? raw : '${raw}Z').toLocal();
}

DateTime? tryParseServerUtc(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  try {
    return parseServerUtc(raw);
  } on FormatException {
    return null;
  }
}
