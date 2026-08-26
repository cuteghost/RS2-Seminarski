import 'package:flutter/foundation.dart';

import 'package:ebooking_desktop/models/profile_model.dart';
import 'package:ebooking_desktop/services/api_response_handler.dart';
import 'package:ebooking_desktop/services/profile_service.dart';

/// Profil prijavljenog administratora.
///
/// BUGFIX: `_profile` je ranije bio `late Profile` bez inicijalizacije, pa je
/// SVAKI pristup prije `getProfile()` bacao `LateInitializationError`. To je
/// pucalo npr. u `messenger_screen.dart`, koji čita `profile.id` u `build`-u.
/// Sada se startuje sa `Profile.empty` i UI može sigurno čitati.
class ProfileProvider with ChangeNotifier {
  final ProfileService profileService;

  ProfileProvider({required this.profileService});

  Profile _profile = Profile.empty;
  String? _error;

  Profile get profile => _profile;
  String? get error => _error;
  bool get isLoaded => _profile.id.isNotEmpty;

  Future<Profile> getProfile() async {
    try {
      _profile = await profileService.fetchProfile();
      _error = null;
    } catch (e) {
      _error = ApiResponseHandler.describe(e);
    }
    notifyListeners();
    return _profile;
  }

  /// Vraća (success, message) — isti obrazac kao mobilni klijent, da modal
  /// zna da li da se zatvori i šta da prikaže.
  ///
  /// Upute 4: poruke o grešci moraju eksplicitno navoditi format i ograničenja
  /// unosa. Zato validacija e-maila daje konkretnu poruku, ne "Invalid input".
  Future<({bool success, String message})> updateEmail(
    String newEmail,
    String password,
  ) async {
    if (newEmail.trim().isEmpty || password.isEmpty) {
      return (success: false, message: 'Popunite oba polja.');
    }

    final emailRegex = RegExp(r'^[\w.\-]+@([\w\-]+\.)+[A-Za-z]{2,}$');
    if (!emailRegex.hasMatch(newEmail.trim())) {
      return (
        success: false,
        message: 'Unesite ispravnu e-mail adresu u formatu: ime@domena.ba',
      );
    }

    try {
      final message = await profileService.updateEmail(newEmail.trim(), password);
      await getProfile();
      return (success: true, message: message);
    } catch (e) {
      return (success: false, message: ApiResponseHandler.describe(e));
    }
  }

  Future<({bool success, String message})> updatePassword(
    String oldPassword,
    String newPassword,
  ) async {
    if (oldPassword.isEmpty || newPassword.isEmpty) {
      return (success: false, message: 'Popunite oba polja.');
    }
    if (newPassword.length < 8) {
      return (
        success: false,
        message: 'Nova lozinka mora imati najmanje 8 znakova.',
      );
    }

    try {
      final message =
          await profileService.updatePassword(oldPassword, newPassword);
      return (success: true, message: message);
    } catch (e) {
      return (success: false, message: ApiResponseHandler.describe(e));
    }
  }

  void reset() {
    _profile = Profile.empty;
    _error = null;
    notifyListeners();
  }
}
