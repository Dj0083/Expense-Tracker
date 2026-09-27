/// The data associated with one expense.
class Expense {
  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.notes,
  });

  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? notes;

  static const categories = [
    'Food',
    'Transport',
    'Shopping',
    'Bills',
    'Health',
    'Education',
    'Entertainment',
    'Other',
  ];

  Map<String, Object?> toMap() => {
    'title': title,
    'amount': amount,
    'category': category,
    'date': date.toIso8601String(),
    'notes': notes,
  };

  factory Expense.fromMap(String id, Map<String, dynamic> map) {
    return Expense(
      id: id,
      title: map['title'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      category: map['category'] as String? ?? 'Other',
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      notes: map['notes'] as String?,
    );
  }
}
