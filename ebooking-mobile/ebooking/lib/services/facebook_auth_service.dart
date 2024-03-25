import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:ebooking/models/user_model.dart';

class FacebookAuthService {
  Future<UserModel?> login() async {
    final LoginResult result = await FacebookAuth.instance.login();
    if (result.status == LoginStatus.success) {
      final userData = await FacebookAuth.instance.getUserData();
      return UserModel.fromJson(userData);
    }
    return null;
  }

  Future<void> logout() async {
    await FacebookAuth.instance.logOut();
  }

  Future<UserModel?> checkLoggedIn() async {
    final accessToken = await FacebookAuth.instance.accessToken;
    if (accessToken != null) {
      final userData = await FacebookAuth.instance.getUserData();
      return UserModel.fromJson(userData);
    }
    return null;
  }
}
