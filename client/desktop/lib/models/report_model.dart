enum ReportInterval {
  day('Day', 'Daily'),
  week('Week', 'Weekly'),
  month('Month', 'Monthly');

  const ReportInterval(this.apiValue, this.label);

  final String apiValue;
  final String label;
}

class GrowthPoint {
  final DateTime periodStart;
  final String label;
  final int newAccommodations;
  final int newUsers;
  final int totalAccommodations;
  final int totalUsers;

  const GrowthPoint({
    required this.periodStart,
    required this.label,
    required this.newAccommodations,
    required this.newUsers,
    required this.totalAccommodations,
    required this.totalUsers,
  });

  factory GrowthPoint.fromJson(Map<String, dynamic> json) => GrowthPoint(
        periodStart: DateTime.tryParse(json['periodStart']?.toString() ?? '') ??
            DateTime(2000),
        label: json['label']?.toString() ?? '',
        newAccommodations: (json['newAccommodations'] as num?)?.toInt() ?? 0,
        newUsers: (json['newUsers'] as num?)?.toInt() ?? 0,
        totalAccommodations:
            (json['totalAccommodations'] as num?)?.toInt() ?? 0,
        totalUsers: (json['totalUsers'] as num?)?.toInt() ?? 0,
      );
}

class TopCustomer {
  final String userId;
  final String displayName;
  final String email;
  final int paymentCount;
  final double totalPaid;

  const TopCustomer({
    required this.userId,
    required this.displayName,
    required this.email,
    required this.paymentCount,
    required this.totalPaid,
  });

  factory TopCustomer.fromJson(Map<String, dynamic> json) => TopCustomer(
        userId: json['userId']?.toString() ?? '',
        displayName: json['displayName']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        paymentCount: (json['paymentCount'] as num?)?.toInt() ?? 0,
        totalPaid: (json['totalPaid'] as num?)?.toDouble() ?? 0,
      );
}

class TopAccommodation {
  final String accommodationId;
  final String name;
  final String cityName;
  final int paymentCount;
  final double totalRevenue;

  const TopAccommodation({
    required this.accommodationId,
    required this.name,
    required this.cityName,
    required this.paymentCount,
    required this.totalRevenue,
  });

  factory TopAccommodation.fromJson(Map<String, dynamic> json) =>
      TopAccommodation(
        accommodationId: json['accommodationId']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        cityName: json['cityName']?.toString() ?? '',
        paymentCount: (json['paymentCount'] as num?)?.toInt() ?? 0,
        totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
      );
}

class ReportOverview {
  final DateTime from;
  final DateTime to;
  final String currency;
  final int newAccommodations;
  final int newUsers;
  final double totalRevenue;
  final List<GrowthPoint> growth;
  final List<TopCustomer> topCustomers;
  final List<TopAccommodation> topAccommodations;
  final String growthSvg;
  final String topCustomersSvg;
  final String topAccommodationsSvg;

  const ReportOverview({
    required this.from,
    required this.to,
    required this.currency,
    required this.newAccommodations,
    required this.newUsers,
    required this.totalRevenue,
    required this.growth,
    required this.topCustomers,
    required this.topAccommodations,
    required this.growthSvg,
    required this.topCustomersSvg,
    required this.topAccommodationsSvg,
  });

  static List<T> _list<T>(dynamic raw, T Function(Map<String, dynamic>) parse) =>
      raw is List
          ? raw
              .whereType<Map>()
              .map((e) => parse(e.map((k, v) => MapEntry(k.toString(), v))))
              .toList()
          : <T>[];

  factory ReportOverview.fromJson(Map<String, dynamic> json) {
    final charts = json['charts'] is Map
        ? (json['charts'] as Map).map((k, v) => MapEntry(k.toString(), v))
        : const <String, dynamic>{};
    return ReportOverview(
      from: DateTime.tryParse(json['from']?.toString() ?? '') ?? DateTime.now(),
      to: DateTime.tryParse(json['to']?.toString() ?? '') ?? DateTime.now(),
      currency: json['currency']?.toString() ?? 'USD',
      newAccommodations: (json['newAccommodations'] as num?)?.toInt() ?? 0,
      newUsers: (json['newUsers'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
      growth: _list(json['growth'], GrowthPoint.fromJson),
      topCustomers: _list(json['topCustomers'], TopCustomer.fromJson),
      topAccommodations:
          _list(json['topAccommodations'], TopAccommodation.fromJson),
      growthSvg: charts['growthSvg']?.toString() ?? '',
      topCustomersSvg: charts['topCustomersSvg']?.toString() ?? '',
      topAccommodationsSvg: charts['topAccommodationsSvg']?.toString() ?? '',
    );
  }
}
