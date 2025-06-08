class Expense {
  String title;
  double amount;
  String uuid;

  Expense({required this.title, required this.amount, required this.uuid});

  factory Expense.fromJson(Map<String, dynamic> json) {
    final data = json['expense_list'] as Map<String, dynamic>;
    return Expense(
      title: data['title'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      uuid: data['uuid'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'uuid': uuid
    };
  }
}