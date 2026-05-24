class MonthlyBudget {
  final String month;
  final int profileId;
  final double targetAmount;

  MonthlyBudget({
    required this.month,
    required this.profileId,
    required this.targetAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'month': month,
      'profileId': profileId,
      'targetAmount': targetAmount,
    };
  }

  factory MonthlyBudget.fromMap(Map<String, dynamic> map) {
    return MonthlyBudget(
      month: map['month'] as String,
      profileId: map['profileId'] as int,
      targetAmount: (map['targetAmount'] as num).toDouble(),
    );
  }
}
