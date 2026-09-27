import 'package:expense_tracker/features/expenses/models/expense.dart';
import 'package:expense_tracker/features/expenses/widgets/expense_category_chart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buildCategoryTotals groups expenses by category', () {
    final expenses = [
      Expense(
        id: '1',
        title: 'Lunch',
        amount: 25,
        category: 'Food',
        date: DateTime(2026, 9, 1),
      ),
      Expense(
        id: '2',
        title: 'Bus ticket',
        amount: 10,
        category: 'Transport',
        date: DateTime(2026, 9, 2),
      ),
      Expense(
        id: '3',
        title: 'Course book',
        amount: 35,
        category: 'Education',
        date: DateTime(2026, 9, 3),
      ),
      Expense(
        id: '4',
        title: 'Groceries',
        amount: 25,
        category: 'Food',
        date: DateTime(2026, 9, 4),
      ),
    ];

    final totals = ExpenseCategoryChart.buildCategoryTotals(expenses);

    expect(totals['Food'], 50);
    expect(totals['Transport'], 10);
    expect(totals['Education'], 35);
    expect(totals.containsKey('Health'), isFalse);
  });
}
