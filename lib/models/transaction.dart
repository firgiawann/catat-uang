class Transaction {
  final int? id;
  final String month;
  final int profileId;
  final double amount;
  final bool isExpense;
  final String note;
  final int timestamp;

  Transaction({
    this.id,
    required this.month,
    required this.profileId,
    required this.amount,
    required this.isExpense,
    required this.note,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'month': month,
      'profileId': profileId,
      'amount': amount,
      'isExpense': isExpense ? 1 : 0,
      'note': note,
      'timestamp': timestamp,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      month: map['month'] as String,
      profileId: map['profileId'] as int,
      amount: (map['amount'] as num).toDouble(),
      isExpense: (map['isExpense'] as int) == 1,
      note: map['note'] as String,
      timestamp: map['timestamp'] as int,
    );
  }
}
