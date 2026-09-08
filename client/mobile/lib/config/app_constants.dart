/// Role names exactly as the server writes them into the JWT role claim
/// (`Models/Constants/Roles.cs`).
///
/// They used to sit as literals in `auth_service.dart`, `main.dart` and
/// `login_screen.dart`. A typo in any one of them did not fail — it quietly
/// routed the user to the wrong home screen. Only the two roles the mobile app
/// can be signed in as are listed; `Administrator` is a desktop role.
class Roles {
  const Roles._();

  static const String partner = 'Partner';
  static const String customer = 'Customer';
  static const String administrator = 'Administrator';

  static const Set<String> all = <String>{partner, customer, administrator};
}

/// Claim names in the JWT the server issues.
class JwtClaims {
  const JwtClaims._();

  static const String role =
      'http://schemas.microsoft.com/ws/2008/06/identity/claims/role';
  static const String shortRole = 'role';
  static const String expiry = 'exp';
  static const String userId =
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier';
  static const String shortUserId = 'nameid';
  static const String email =
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress';
  static const String shortEmail = 'email';
}

/// Paging limits, mirroring `Models/Constants/Pagination.cs` on the server.
///
/// The server clamps rather than rejects — below the minimum or above the
/// maximum is corrected, so a list endpoint never answers `400` over paging.
class ApiPagination {
  const ApiPagination._();

  static const int firstPage = 1;
  static const int defaultPageSize = 10;
  static const int maxPageSize = 100;
}

class SuggestionLimits {
  const SuggestionLimits._();

  static const int topCount = 10;
}

class NearbyLimits {
  const NearbyLimits._();

  static const int topCount = 10;
}

class AccommodationPhotos {
  const AccommodationPhotos._();

  static const int required = 5;
  static const int maximum = 20;
}
