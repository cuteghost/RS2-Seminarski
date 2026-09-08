import 'package:ebooking/models/partner_model.dart';
import 'package:ebooking/models/profile_model.dart';
import 'package:ebooking/services/api_client.dart';
import 'package:ebooking/services/secure_storage.dart';

Map<String, dynamic> _object(dynamic data) => data as Map<String, dynamic>;

class ProfileService {
  ProfileService({required this._apiClient, required this._secureStorage});

  final ApiClient _apiClient;
  final SecureStorage _secureStorage;

  Future<Profile> fetchProfile() async {
    return Profile.fromJson(
      await _apiClient.get<Map<String, dynamic>>(
        '/api/Customer/Details',
        parse: _object,
      ),
    );
  }

  Future<Profile> updateProfile(Profile profile) async {
    return Profile.fromJson(
      await _apiClient.patch<Map<String, dynamic>>(
        '/api/Customer/UpdateDetails',
        body: profile.toJson(),
        parse: _object,
      ),
    );
  }

  /// Changing the email or the password reissues the token: the old one holds
  /// the old email and was signed before the change.
  Future<void> updateEmail(String newEmail, String password) async {
    final token = await _apiClient.patch<String>(
      '/api/User/UpdateEmail',
      body: <String, String>{'email': newEmail, 'password': password},
      parse: (data) => _object(data)['token'] as String,
    );
    await _secureStorage.saveToken(token);
  }

  Future<void> updatePassword(String oldPassword, String newPassword) async {
    final token = await _apiClient.patch<String>(
      '/api/User/UpdatePassword',
      body: <String, String>{
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
      parse: (data) => _object(data)['token'] as String,
    );
    await _secureStorage.saveToken(token);
  }

  Future<Partner> fetchPartner() async {
    return Partner.fromJson(
      await _apiClient.get<Map<String, dynamic>>(
        '/api/Partner/PartnerDetails',
        parse: _object,
      ),
    );
  }

  Future<Partner> updatePartner(Partner partner) async {
    return Partner.fromJson(
      await _apiClient.patch<Map<String, dynamic>>(
        '/api/Partner/Update',
        body: partner.toJson(),
        parse: _object,
      ),
    );
  }
}
