import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class Profile {
  String id;
  String displayName;
  String firstName;
  String lastName;
  String dob;
  String emailAddress;
  File profilePicture;
  String gender;
  String socialLink;
  String customerId;
  Profile({
    required this.id,
    required this.displayName,
    required this.firstName,
    required this.lastName,
    required this.emailAddress,
    required this.dob,
    required this.profilePicture,
    required this.gender,
    required this.socialLink,
    required this.customerId,
  });

  static Future<Profile> fromJson(jsonDecode) async {
    Uint8List profilePictureBytes = base64Decode(jsonDecode['userImage']);
    Directory tempDir = await Directory.systemTemp.createTemp('profilePicture');
    File profilePictureFile = File('${tempDir.path}/profilePicture.jpg');
    await profilePictureFile.writeAsBytes(profilePictureBytes);
    
    String genderFromJson = "";
    if (jsonDecode['userGender'] == 0) {
      genderFromJson = "Male";
    } else {
      genderFromJson = "Female";
    }
    String dateOfBirth = jsonDecode['userBirthDate'];
    String parsedDateOfBirth = dateOfBirth.substring(0, 10);
    return Future.value(
      Profile(
        id: jsonDecode['userId'],
        displayName: jsonDecode['userDisplayName'],
        firstName: jsonDecode['userFirstName'],
        lastName: jsonDecode['userLastName'],
        emailAddress: jsonDecode['userEmail'],
        dob: parsedDateOfBirth,
        profilePicture: profilePictureFile,
        gender: genderFromJson,
        socialLink: jsonDecode['userSocialLink'],
        customerId: jsonDecode['id'],

      )
    );
  }

  Map<String, dynamic> toJson() {
    List<int> imageBytes = profilePicture.readAsBytesSync();
    String base64image = base64Encode(imageBytes);
    int genderToPass;
    if (gender == "Male") {
      genderToPass = 0;
    }
    else {
      genderToPass = 1;
    }
    return {
      'displayName': displayName,
      'firstName': firstName,
      'lastName': lastName,
      'email': emailAddress,
      'birthDate': dob,
      'image': base64image,
      'gender': genderToPass,
    };
  }
}

