import 'dart:convert';
import 'dart:typed_data';

/// Odgovara backend DTO-u `Models.DTO.UserDTO.UserGET` (i njegovom
/// nasljedniku `CustomerGET`), te `AdministratorGET`.
///
/// PAŽNJA na neusklađeno imenovanje na backendu:
///  - `UserGET` koristi `UserId`, `UserDisplayName`, ... `UserisActive`
///  - `AdministratorGET` koristi `userId`, `userDisplayName`, ... `IsActive`
/// Serijalizacija je camelCase, pa oba stižu kao `userId`/`userDisplayName`,
/// ALI se aktivnost razlikuje: `userisActive` vs `isActive`. Parsing ispod
/// podnosi oba ključa. To je backend nekonzistentnost (Upute 3.1: "Modeli,
/// DTO objekti i request objekti moraju biti konzistentni") — prijavljena je
/// u izvještaju, a klijent je do ispravke defanzivan.
enum UserRole {
  administrator('Administrator'),
  customer('Klijent'),
  partner('Partner');

  final String label;
  const UserRole(this.label);

  static UserRole fromJson(dynamic value) {
    if (value is num) {
      final index = value.toInt();
      if (index >= 0 && index < values.length) return values[index];
    }
    if (value is String) {
      for (final role in values) {
        if (role.name.toLowerCase() == value.toLowerCase()) return role;
      }
    }
    return UserRole.customer;
  }
}

enum UserGender {
  male('Muški'),
  female('Ženski');

  final String label;
  const UserGender(this.label);

  static UserGender fromJson(dynamic value) =>
      (value is num && value.toInt() == 1) ? female : male;
}

class Profile {
  final String id;
  final String displayName;
  final String firstName;
  final String lastName;

  /// `yyyy-MM-dd`, već skraćeno sa backend `DateTime`.
  final String dob;
  final String emailAddress;

  /// BUGFIX: ranije je ovo bio `File` koji je `fromJson` pisao na disk, i
  /// dekodiran je BEZ null-provjere (`base64Decode(json['userImage'])`).
  /// Jedan korisnik bez slike rušio je parsiranje CIJELE liste korisnika.
  /// Sada: opciono, u memoriji, bez disk I/O.
  final Uint8List? profilePicture;

  final UserGender gender;
  final UserRole role;
  final String socialLink;
  final bool isActive;

  const Profile({
    required this.id,
    required this.displayName,
    required this.firstName,
    required this.lastName,
    required this.emailAddress,
    required this.dob,
    required this.gender,
    required this.role,
    required this.socialLink,
    required this.isActive,
    this.profilePicture,
  });

  /// Sinhrono — nema više `async` jer nema disk zapisa.
  /// (Ranije je bio `static Future<Profile> fromJson(...)` samo zato što je
  /// pisao temp fajl, što je onda tjeralo `Future.wait` po servisima.)
  factory Profile.fromJson(Map<String, dynamic> json) {
    Uint8List? image;
    final rawImage = json['userImage'] ?? json['UserImage'];
    if (rawImage is String && rawImage.isNotEmpty) {
      try {
        image = base64Decode(rawImage);
      } on FormatException {
        image = null;
      }
    } else if (rawImage is List) {
      // ASP.NET može serijalizovati byte[] kao niz brojeva.
      image = Uint8List.fromList(rawImage.whereType<num>()
          .map((n) => n.toInt())
          .toList());
    }

    final rawDob = (json['userBirthDate'] ?? json['UserBirthDate'])?.toString();
    final dob = (rawDob != null && rawDob.length >= 10)
        ? rawDob.substring(0, 10)
        : '';

    return Profile(
      // `CustomerGET` ima i `id` (Customer.Id) i `userId` (User.Id).
      // Za chat/brisanje treba `userId`, pa on ima prednost.
      id: (json['userId'] ?? json['id'] ?? '').toString(),
      displayName: json['userDisplayName']?.toString() ?? '',
      firstName: json['userFirstName']?.toString() ?? '',
      lastName: json['userLastName']?.toString() ?? '',
      emailAddress: json['userEmail']?.toString() ?? '',
      dob: dob,
      profilePicture: image,
      gender: UserGender.fromJson(json['userGender']),
      role: UserRole.fromJson(json['role'] ?? json['Role']),
      socialLink: json['userSocialLink']?.toString() ?? '',
      // Vidi napomenu na vrhu: dva različita ključa za istu stvar.
      isActive: (json['userisActive'] ?? json['isActive'] ?? true) == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'firstName': firstName,
        'lastName': lastName,
        'email': emailAddress,
        'birthDate': dob,
        'image': profilePicture == null ? '' : base64Encode(profilePicture!),
        'gender': gender.index,
      };

  /// Ime za prikaz — pada na displayName pa na email, da tabela nikad
  /// ne pokaže prazan red.
  String get fullName {
    final joined = [firstName, lastName].where((p) => p.isNotEmpty).join(' ');
    if (joined.isNotEmpty) return joined;
    if (displayName.isNotEmpty) return displayName;
    return emailAddress;
  }

  static Profile get empty => const Profile(
        id: '',
        displayName: '',
        firstName: '',
        lastName: '',
        emailAddress: '',
        dob: '',
        gender: UserGender.male,
        role: UserRole.customer,
        socialLink: '',
        isActive: true,
      );
}
