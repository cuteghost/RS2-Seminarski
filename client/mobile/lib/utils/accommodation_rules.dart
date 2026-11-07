/// Mirrors `AccommodationRules` on the server so the partner sees the same
/// limits before sending. The server stays the authority and checks them again.
class AccommodationRules {
  const AccommodationRules._();

  static const int nameMin = 3;
  static const int nameMax = 50;
  static const int descriptionMin = 50;
  static const int descriptionMax = 1000;
  static const double priceMax = 100000;
  static const int bedsMin = 1;
  static const int bedsMax = 50;

  static String? name(String? value) {
    final text = value?.trim() ?? '';
    if (text.length < nameMin || text.length > nameMax) {
      return 'The name must have between $nameMin and $nameMax characters';
    }
    return null;
  }

  static String? description(String? value) {
    final text = value?.trim() ?? '';
    if (text.length < descriptionMin || text.length > descriptionMax) {
      return 'The description must have between $descriptionMin and $descriptionMax characters';
    }
    return null;
  }

  static String? price(String? value) {
    final parsed = double.tryParse((value ?? '').trim());
    if (parsed == null) return 'Enter a valid number';
    if (parsed <= 0 || parsed > priceMax) {
      return 'The price must be greater than 0 and at most ${priceMax.toStringAsFixed(0)}';
    }
    return null;
  }

  static String? beds(String? value) {
    final parsed = int.tryParse((value ?? '').trim());
    if (parsed == null) return 'Enter a whole number';
    if (parsed < bedsMin || parsed > bedsMax) {
      return 'The number of beds must be between $bedsMin and $bedsMax';
    }
    return null;
  }
}
