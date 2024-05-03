import 'package:ebooking/models/partner_model.dart';
import 'package:flutter/material.dart';
import 'package:ebooking/models/profile_model.dart';
import 'package:ebooking/services/profile_service.dart';

class ProfileProvider with ChangeNotifier {
  Profile? profile;
  final ProfileService profileService;

  ProfileProvider({required this.profileService});

  Future<bool> updateProfile({required Profile profile}) async{
    return await profileService.updateProfile(profile);
  }

  Future<Profile> getProfile() async {
    return await profileService.fetchProfile();
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
  Future<Partner> getPartner() async {
    return await profileService.fetchPartner();
  }

  updatePartner({required Partner partner}) async {
    await profileService.updatePartner(partner);
  }
}