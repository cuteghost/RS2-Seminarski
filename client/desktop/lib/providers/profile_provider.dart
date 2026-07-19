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

  Future<({bool success, String message})> updatePersonalDetails(
    Profile updated,
  ) async {
    try {
      final result = await profileService.updatePersonalDetails(updated);
      _profile = result.profile;
      _error = null;
      notifyListeners();
      return (success: true, message: result.message);
    } catch (e) {
      return (success: false, message: ApiResponseHandler.describe(e));
    }
  }

  /// Vraća (success, message) — isti obrazac kao mobilni klijent, da modal
  /// zna da li da se zatvori i šta da prikaže.
  Future<({bool success, String message})> updateEmail(
    String newEmail,
    String password,
  ) async {
    if (newEmail.trim().isEmpty || password.isEmpty) {
      return (success: false, message: 'Fill in both fields.');
    }

    final emailRegex = RegExp(r'^[\w.\-]+@([\w\-]+\.)+[A-Za-z]{2,}$');
    if (!emailRegex.hasMatch(newEmail.trim())) {
      return (
        success: false,
        message: 'Enter a valid email address in the format: name@domain.ba',
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
      return (success: false, message: 'Fill in both fields.');
    }
    if (newPassword.length < 8) {
      return (
        success: false,
        message: 'The new password must be at least 8 characters long.',
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
