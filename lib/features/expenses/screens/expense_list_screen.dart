import 'package:flutter/material.dart';

import '../data/expense_repository.dart';
import '../models/expense.dart';
import '../widgets/expense_category_chart.dart';
import '../widgets/expense_list_item.dart';
import 'expense_form_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({
    required this.repository,
    this.isDarkMode = false,
    this.onToggleTheme,
    super.key,
  });

  final ExpenseRepository repository;
  final bool isDarkMode;
  final VoidCallback? onToggleTheme;

  static bool matchesSearchQuery(Expense expense, String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return true;

    return expense.title.toLowerCase().contains(normalizedQuery) ||
        (expense.notes != null &&
            expense.notes!.toLowerCase().contains(normalizedQuery)) ||
        expense.category.toLowerCase().contains(normalizedQuery) ||
        expense.amount.toStringAsFixed(2).contains(normalizedQuery);
  }

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  String? _categoryFilter;
  DateTime? _dateFilter;
  final TextEditingController _searchController = TextEditingController();

  String _monthLabel(DateTime date) => '${_monthName(date.month)} ${date.year}';

  String _monthName(int month) =>
      const [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ][month - 1];

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  Future<void> _openForm([Expense? expense]) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder:
            (_) => ExpenseFormScreen(
              repository: widget.repository,
              expense: expense,
            ),
      ),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 10),
                Text('Expense saved'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  Future<void> _delete(Expense expense) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete expense?'),
            content: Text('Remove “${expense.title}” from your history?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (confirm != true || !mounted) return;
    try {
      await widget.repository.deleteExpense(expense.id);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete expense: $error')),
        );
      }
    }
  }

  Future<void> _pickFilterDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _dateFilter ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (selected != null) setState(() => _dateFilter = selected);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My expenses',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: widget.onToggleTheme,
            icon: Icon(
              widget.isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
          IconButton(
            tooltip: 'Clear filters',
            onPressed:
                _categoryFilter == null && _dateFilter == null
                    ? null
                    : () => setState(() {
                      _categoryFilter = null;
                      _dateFilter = null;
                    }),
            icon: const Icon(Icons.filter_alt_off_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add expense'),
      ),
      body: StreamBuilder<List<Expense>>(
        stream: widget.repository.watchExpenses(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _MessageState(
              icon: Icons.cloud_off_outlined,
              title: 'Couldn’t load expenses',
              message:
                  'Check your connection and Firestore setup, then try again.',
              action: TextButton.icon(
                onPressed: () => setState(() {}),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final expenses = snapshot.data!;
          final searchQuery = _searchController.text.trim().toLowerCase();
          final monthlyTotal = expenses
              .where(
                (expense) =>
                    expense.date.year == now.year &&
                    expense.date.month == now.month,
              )
              .fold<double>(0, (total, expense) => total + expense.amount);
          final filtered =
              expenses.where((expense) {
                final matchesCategory =
                    _categoryFilter == null ||
                    expense.category == _categoryFilter;
                final matchesDate =
                    _dateFilter == null ||
                    (expense.date.year == _dateFilter!.year &&
                        expense.date.month == _dateFilter!.month &&
                        expense.date.day == _dateFilter!.day);
                final matchesSearch =
                    ExpenseListScreen.matchesSearchQuery(
                      expense,
                      searchQuery,
                    );
                return matchesCategory && matchesDate && matchesSearch;
              }).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            children: [
              _SummaryCard(total: monthlyTotal, month: _monthLabel(now)),
              const SizedBox(height: 26),
              if (filtered.isNotEmpty) ...[
                ExpenseCategoryChart(expenses: filtered),
                const SizedBox(height: 22),
              ],
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'History',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '${filtered.length} items',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search expenses',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  isDense: true,
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                          : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...Expense.categories.map(
                      (category) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: _categoryFilter == category,
                          onSelected:
                              (selected) => setState(
                                () =>
                                    _categoryFilter =
                                        selected ? category : null,
                              ),
                        ),
                      ),
                    ),
                    ActionChip(
                      avatar: const Icon(
                        Icons.calendar_today_outlined,
                        size: 17,
                      ),
                      label: Text(
                        _dateFilter == null
                            ? 'Date'
                            : _formatDate(_dateFilter!),
                      ),
                      onPressed: _pickFilterDate,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (expenses.isEmpty)
                _MessageState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No expenses yet',
                  message:
                      'Add your first expense to start seeing where your money goes.',
                  action: FilledButton.icon(
                    onPressed: () => _openForm(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add first expense'),
                  ),
                )
              else if (filtered.isEmpty)
                const _MessageState(
                  icon: Icons.filter_list_off,
                  title: 'No matching expenses',
                  message: 'Try another category or clear your filters.',
                )
              else
                ...filtered.map(
                  (expense) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ExpenseListItem(
                      expense: expense,
                      dateLabel: _formatDate(expense.date),
                      onTap: () => _openForm(expense),
                      onDelete: () => _delete(expense),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.total, required this.month});

  final double total;
  final String month;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF087F68), Color(0xFF25A987)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white70,
              ),
              SizedBox(width: 8),
              Text(
                'TOTAL SPENT',
                style: TextStyle(
                  color: Colors.white70,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Rs ${total.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                size: 17,
                color: Colors.white70,
              ),
              const SizedBox(width: 6),
              Text(month, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 12),
      child: Column(
        children: [
          Icon(icon, size: 42, color: colors.primary),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}
