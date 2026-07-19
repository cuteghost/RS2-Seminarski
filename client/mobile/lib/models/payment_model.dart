enum PaymentStatus {
  notStarted(0, 'Not started'),
  created(1, 'Started'),
  paid(2, 'Paid'),
  failed(3, 'Failed');

  const PaymentStatus(this.value, this.label);

  final int value;
  final String label;

  static PaymentStatus fromValue(int value) => values.firstWhere(
    (status) => status.value == value,
    orElse: () => notStarted,
  );
}

class PaymentGET {
  final String? id;
  final String reservationId;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final String? provider;
  final DateTime? createdAt;
  final DateTime? completedAt;
  final bool isPaid;

  PaymentGET({
    required this.reservationId,
    required this.amount,
    required this.currency,
    required this.status,
    required this.isPaid,
    this.id,
    this.provider,
    this.createdAt,
    this.completedAt,
  });

  factory PaymentGET.fromJson(Map<String, dynamic> json) {
    return PaymentGET(
      id: json['id'] as String?,
      reservationId: json['reservationId'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? '',
      status: PaymentStatus.fromValue((json['status'] as num?)?.toInt() ?? 0),
      provider: json['provider'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      isPaid: json['isPaid'] as bool? ?? false,
    );
  }
}
