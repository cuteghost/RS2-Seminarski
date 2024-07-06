import 'package:ebooking_desktop/models/partner_model.dart';
import 'package:flutter/material.dart';
import 'package:ebooking_desktop/models/profile_model.dart';
import 'package:ebooking_desktop/services/profile_service.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileService profileService;
  ProfileProvider({required this.profileService});
  
  late Profile _profile;
  Profile get profile => _profile;

  Future<bool> updateProfile({required Profile profile}) async{
    return await profileService.updateProfile(profile);
  }

  Future<Profile> getProfile() async {
    _profile = await profileService.fetchProfile();
    notifyListeners();
    return _profile;
  }

  Future<String> updateEmail(String newEmail, String password) async {
    if(newEmail == '' || password == '') {
      return 'Please fill in all fields';
    }
    //regex to validate email
    RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if(newEmail != '' && emailRegex.hasMatch(newEmail)) {
      if(await profileService.updateEmail(newEmail, password) == true)
      {
        return 'Email updated successfully';
      }
      else { 
        return 'Failed to update email';
      }
    }
    else {
      return 'Invalid email address';
    }
  }

  Future<String> updatePassword(String oldPassword, String newPassword) async {
    if(oldPassword == '' || newPassword == '') {
      return 'Please fill in all fields';
    }
    if(await profileService.updatePassword(oldPassword, newPassword) == true)
    {
      return 'Password updated successfully';
    }
    else {
      return 'Failed to update password';
    }
  }
}