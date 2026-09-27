import 'package:flutter/material.dart';

import '../models/expense.dart';

class ExpenseListItem extends StatelessWidget {
  const ExpenseListItem({
    required this.expense,
    required this.dateLabel,
    required this.onTap,
    required this.onDelete,
    super.key,
  });

  final Expense expense;
  final String dateLabel;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  IconData get _categoryIcon => switch (expense.category) {
    'Food' => Icons.restaurant_outlined,
    'Transport' => Icons.directions_car_outlined,
    'Shopping' => Icons.shopping_bag_outlined,
    'Bills' => Icons.receipt_long_outlined,
    'Health' => Icons.favorite_border,
    'Entertainment' => Icons.movie_outlined,
    _ => Icons.payments_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(_categoryIcon, color: colors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${expense.category} · $dateLabel',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    if (expense.notes != null && expense.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        expense.notes!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Rs ${expense.amount.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              PopupMenuButton<String>(
                tooltip: 'Expense actions',
                onSelected: (value) {
                  if (value == 'delete') onDelete();
                  if (value == 'edit') onTap();
                },
                itemBuilder:
                    (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
