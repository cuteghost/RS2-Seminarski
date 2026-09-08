import 'package:ebooking/models/partner_model.dart';
import 'package:ebooking/models/profile_model.dart';
import 'package:ebooking/services/api_client.dart';
import 'package:ebooking/services/profile_service.dart';
import 'package:flutter/material.dart';

/// `(success, message)`. The caller uses `success` to decide whether to close
/// the modal — it should stay open on failure so the user can see the error and
/// correct it, instead of silently closing either way. On failure `message` is
/// the API's own text, word for word.
typedef ProfileResult = (bool success, String message);

class ProfileProvider with ChangeNotifier {
  final ProfileService profileService;
  ProfileProvider({required this.profileService});

  Profile? _profile;
  Profile? get profile => _profile;

  Future<Profile> getProfile() async {
    final profile = await profileService.fetchProfile();
    _profile = profile;
    notifyListeners();
    return profile;
  }

  void clear() {
    _profile = null;
    notifyListeners();
  }

  Future<ProfileResult> updateProfile({required Profile profile}) async {
    try {
      _profile = await profileService.updateProfile(profile);
      notifyListeners();
      return (true, 'Your details have been updated.');
    } on ApiException catch (e) {
      return (false, e.message);
    }
  }

  Future<ProfileResult> updateEmail(String newEmail, String password) async {
    if (newEmail == '' || password == '') {
      return (false, 'Please fill in all fields');
    }
    RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(newEmail)) {
      return (false, 'Please enter a valid email address');
    }
    try {
      await profileService.updateEmail(newEmail, password);
      // Keep the in-memory profile in sync so screens reading it immediately
      // reflect the change without needing a full re-fetch.
      _profile?.emailAddress = newEmail;
      notifyListeners();
      return (true, 'Email updated successfully');
    } on ApiException catch (e) {
      return (false, e.message);
    }
  }

  Future<ProfileResult> updatePassword(
    String oldPassword,
    String newPassword,
  ) async {
    if (oldPassword == '' || newPassword == '') {
      return (false, 'Please fill in all fields');
    }
    try {
      await profileService.updatePassword(oldPassword, newPassword);
      return (true, 'Password updated successfully');
    } on ApiException catch (e) {
      return (false, e.message);
    }
  }

  Future<Partner> getPartner() {
    return profileService.fetchPartner();
  }

  Future<ProfileResult> updatePartner({required Partner partner}) async {
    try {
      await profileService.updatePartner(partner);
      notifyListeners();
      return (true, 'Your partner details have been updated.');
    } on ApiException catch (e) {
      return (false, e.message);
    }
  }
}
