import 'package:ebooking/models/partner_model.dart';
import 'package:flutter/material.dart';
import 'package:ebooking/models/profile_model.dart';
import 'package:ebooking/services/profile_service.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileService profileService;
  ProfileProvider({required this.profileService});

  late Profile _profile;
  Profile get profile => _profile;

  Future<bool> updateProfile({required Profile profile}) async {
    return await profileService.updateProfile(profile);
  }

  Future<Profile> getProfile() async {
    _profile = await profileService.fetchProfile();
    notifyListeners();
    return _profile;
  }

  /// Returns (success, message). The caller uses `success` to decide whether
  /// to close the modal — it should stay open on failure so the user can see
  /// the error and correct it, instead of silently closing either way.
  Future<(bool success, String message)> updateEmail(
      String newEmail, String password) async {
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
      _profile.emailAddress = newEmail;
      notifyListeners();
      return (true, 'Email updated successfully');
    } catch (e) {
      return (false, 'Incorrect password. Please try again.');
    }
  }

  /// Returns (success, message), same rationale as updateEmail above.
  Future<(bool success, String message)> updatePassword(
      String oldPassword, String newPassword) async {
    if (oldPassword == '' || newPassword == '') {
      return (false, 'Please fill in all fields');
    }
    try {
      await profileService.updatePassword(oldPassword, newPassword);
      return (true, 'Password updated successfully');
    } catch (e) {
      return (false, 'Incorrect old password. Please try again.');
    }
  }

  Future<Partner> getPartner() async {
    return await profileService.fetchPartner();
  }

  Future<bool> updatePartner({required Partner partner}) async {
    return await profileService.updatePartner(partner);
  }
}
