class PaymentCardModel {
  final String id;
  final String userId;
  final String brand;
  final String last4;
  final bool isDefault;

  const PaymentCardModel({
    required this.id,
    required this.userId,
    required this.brand,
    required this.last4,
    required this.isDefault,
  });

  PaymentCardModel copyWith({
    String? brand,
    String? last4,
    bool? isDefault,
  }) {
    return PaymentCardModel(
      id: id,
      userId: userId,
      brand: brand ?? this.brand,
      last4: last4 ?? this.last4,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'brand': brand,
    'last4': last4,
    'isDefault': isDefault,
  };

  factory PaymentCardModel.fromJson(Map<String, dynamic> json) {
    return PaymentCardModel(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      brand: (json['brand'] ?? '').toString(),
      last4: (json['last4'] ?? '').toString(),
      isDefault: (json['isDefault'] as bool?) ?? false,
    );
  }
}
