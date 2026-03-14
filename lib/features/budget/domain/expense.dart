class Expense {
  const Expense({
    required this.id,
    required this.title,
    required this.paidByUserId,
    required this.amount,
    required this.category,
  });

  final String id;
  final String title;
  final String paidByUserId;
  final double amount;
  final String category;
}

class Settlement {
  const Settlement({
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
  });

  final String fromUserId;
  final String toUserId;
  final double amount;
}
