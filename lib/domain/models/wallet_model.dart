class WalletModel {
  final String userId;
  final double balance;
  final bool isHidden;

  const WalletModel({
    required this.userId,
    required this.balance,
    required this.isHidden,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'balance': balance,
    'isHidden': isHidden,
  };

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      userId: (json['userId'] ?? '').toString(),
      balance: (json['balance'] is num) ? (json['balance'] as num).toDouble() : double.tryParse('${json['balance']}') ?? 0,
      isHidden: (json['isHidden'] as bool?) ?? false,
    );
  }
}
