class Partner {
  String id;
  String countryId;
  String taxName;
  int taxId;
  int phoneNumber;

  Partner({
    required this.id,
    required this.countryId,
    required this.taxName,
    required this.taxId,
    required this.phoneNumber
  });

  static Future<Partner> fromJson(jsonDecode) async {
    return Future.value(
      Partner(
        id: jsonDecode['userId'],
        countryId: jsonDecode['countryId'],
        taxName: jsonDecode['taxName'],
        taxId: jsonDecode['taxId'],
        phoneNumber: jsonDecode['phoneNumber'],
      )
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': id,
      'countryId': countryId,
      'taxName': taxName,
      'taxId': taxId,
      'phoneNumber': phoneNumber,
    };
  }
}

