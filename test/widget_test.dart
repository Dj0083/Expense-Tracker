import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:expense_tracker/app/expense_tracker_app.dart';
import 'package:expense_tracker/features/expenses/data/expense_repository.dart';
import 'package:expense_tracker/features/expenses/models/expense.dart';
import 'package:expense_tracker/features/expenses/screens/expense_list_screen.dart';

class _FakeExpenseRepository implements ExpenseRepository {
  const _FakeExpenseRepository();

  @override
  Future<void> deleteExpense(String id) async {}

  @override
  Future<void> saveExpense(Expense expense) async {}

  @override
  Stream<List<Expense>> watchExpenses() => Stream.value(const <Expense>[]);
}

void main() {
  testWidgets('shows the initial expense history placeholder', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ExpenseTrackerApp(repository: _FakeExpenseRepository()),
    );

    await tester.pumpAndSettle();
    expect(find.text('My expenses'), findsOneWidget);
    expect(find.text('No expenses yet'), findsOneWidget);
  });

  testWidgets('switches to dark mode when the theme toggle is tapped', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ExpenseTrackerApp(repository: _FakeExpenseRepository()),
    );

    expect(find.byTooltip('Toggle theme'), findsOneWidget);

    await tester.tap(find.byTooltip('Toggle theme'));
    await tester.pumpAndSettle();

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.themeMode, ThemeMode.dark);
  });

  test('matches the search query across title, notes, category, and amount', () {
    final expense = Expense(
      id: '1',
      title: 'Groceries',
      amount: 30,
      category: 'Food',
      date: DateTime(2026, 9, 1),
      notes: 'Fresh vegetables',
    );

    expect(ExpenseListScreen.matchesSearchQuery(expense, 'gro'), isTrue);
    expect(ExpenseListScreen.matchesSearchQuery(expense, 'vegetable'), isTrue);
    expect(ExpenseListScreen.matchesSearchQuery(expense, 'food'), isTrue);
    expect(ExpenseListScreen.matchesSearchQuery(expense, '30.00'), isTrue);
    expect(ExpenseListScreen.matchesSearchQuery(expense, 'bus'), isFalse);
  });
}
