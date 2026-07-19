import 'dart:convert';
import 'dart:typed_data';

class Partner {
  String? id;
  String userId;
  String countryId;
  String taxName;
  int taxId;
  int phoneNumber;

  String displayName;
  String firstName;
  String lastName;
  String dob;
  String gender;
  String emailAddress;
  String socialLink;
  String? socialProvider;
  bool isSocialAccount;
  final String? imageUrl;
  Uint8List? pickedImage;

  Partner({
    this.id,
    required this.userId,
    required this.countryId,
    required this.taxName,
    required this.taxId,
    required this.phoneNumber,
    this.displayName = '',
    this.firstName = '',
    this.lastName = '',
    this.dob = '',
    this.gender = 'Male',
    this.emailAddress = '',
    this.socialLink = '',
    this.socialProvider,
    this.isSocialAccount = false,
    this.imageUrl,
  });

  factory Partner.fromJson(Map<String, dynamic> json) {
    final userId = json['userId'] as String;
    final rawImage = json['userImage'] as String?;
    final birthDate = json['userBirthDate'] as String?;

    return Partner(
      id: json['id'] as String?,
      userId: userId,
      countryId: json['countryId'] as String,
      taxName: json['taxName'] as String? ?? '',
      taxId: (json['taxId'] as num?)?.toInt() ?? 0,
      phoneNumber: (json['phoneNumber'] as num?)?.toInt() ?? 0,
      displayName: json['userDisplayName'] as String? ?? '',
      firstName: json['userFirstName'] as String? ?? '',
      lastName: json['userLastName'] as String? ?? '',
      dob: birthDate == null || birthDate.length < 10
          ? ''
          : birthDate.substring(0, 10),
      gender: json['userGender'] == 1 ? 'Female' : 'Male',
      emailAddress: json['userEmail'] as String? ?? '',
      socialLink: json['userSocialLink'] as String? ?? '',
      socialProvider: json['userSocialProvider'] as String?,
      isSocialAccount: json['userIsSocialAccount'] as bool? ?? false,
      imageUrl: rawImage == null || rawImage.isEmpty
          ? null
          : '/api/UserImage/$userId',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'countryId': countryId,
      'taxName': taxName,
      'taxId': taxId,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'firstName': firstName,
      'lastName': lastName,
      if (dob.isNotEmpty) 'birthDate': dob,
      'gender': gender == 'Female' ? 1 : 0,
      if (pickedImage != null) 'image': base64Encode(pickedImage!),
    };
  }
}
