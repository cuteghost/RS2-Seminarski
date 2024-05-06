class Partner {
  String? id;
  String userId;
  String countryId;
  String taxName;
  int taxId;
  int phoneNumber;

  Partner({
    this.id,
    required this.userId,
    required this.countryId,
    required this.taxName,
    required this.taxId,
    required this.phoneNumber
  });

  static Future<Partner> fromJson(jsonDecode) async {
    return Future.value(
      Partner(
        id: jsonDecode['id'],
        userId: jsonDecode['userId'],
        countryId: jsonDecode['countryId'],
        taxName: jsonDecode['taxName'],
        taxId: jsonDecode['taxId'],
        phoneNumber: jsonDecode['phoneNumber'],
      )
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'countryId': countryId,
      'taxName': taxName,
      'taxId': taxId,
      'phoneNumber': phoneNumber,
    };
  }
}

