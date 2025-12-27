class Wallet {
  final String id;
  final String userId;
  final double balance;
  final double? lockedBalance;
  final DateTime updatedAt;
  
  Wallet({
    required this.id,
    required this.userId,
    required this.balance,
    this.lockedBalance,
    required this.updatedAt,
  });
  
  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['_id'] ?? json['id'],
      userId: json['userId'] ?? json['user_id'],
      balance: (json['balance'] ?? 0).toDouble(),
      lockedBalance: json['lockedBalance'] != null ? (json['lockedBalance'] as num).toDouble() : null,
      updatedAt: DateTime.parse(json['updatedAt'] ?? json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }
  
  double get availableBalance => balance - (lockedBalance ?? 0);
}

