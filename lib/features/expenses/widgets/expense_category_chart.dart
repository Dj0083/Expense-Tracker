import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/expense.dart';

class ExpenseCategoryChart extends StatelessWidget {
  const ExpenseCategoryChart({required this.expenses, super.key});

  final List<Expense> expenses;

  static Map<String, double> buildCategoryTotals(List<Expense> source) {
    final totals = <String, double>{};

    for (final expense in source) {
      final key = expense.category;
      totals[key] = (totals[key] ?? 0) + expense.amount;
    }

    return totals;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totals = buildCategoryTotals(expenses);
    final entries =
        Expense.categories
            .where((category) => totals.containsKey(category))
            .map((category) {
              final total = totals[category] ?? 0;
              final color =
                  _chartColors[Expense.categories.indexOf(category) %
                      _chartColors.length];
              return _ChartDatum(
                category: category,
                total: total,
                color: color,
              );
            })
            .where((datum) => datum.total > 0)
            .toList();

    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalSpent = entries.fold<double>(
      0,
      (sum, entry) => sum + entry.total,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spending by category',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Rs ${totalSpent.toStringAsFixed(2)}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 42,
                startDegreeOffset: -90,
                sections:
                    entries.map((entry) {
                      final value = entry.total / totalSpent;
                      return PieChartSectionData(
                        value: entry.total,
                        color: entry.color,
                        title: '${(value * 100).toStringAsFixed(0)}%',
                        radius: 70,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children:
                entries.map((entry) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: entry.color,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(entry.category),
                      const SizedBox(width: 2),
                      Text(
                        'Rs ${entry.total.toStringAsFixed(2)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  static const List<Color> _chartColors = [
    Color(0xFF3B82F6),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFF97316),
    Color(0xFF8B5CF6),
    Color(0xFFEF4444),
    Color(0xFF6366F1),
    Color(0xFF14B8A6),
  ];
}

class _ChartDatum {
  const _ChartDatum({
    required this.category,
    required this.total,
    required this.color,
  });

  final String category;
  final double total;
  final Color color;
}
