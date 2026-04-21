import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nudget/core/models/category.dart';
import 'package:nudget/core/models/expense.dart';
import 'package:nudget/core/utils/category_icon_mapper.dart';

/// Compact list tile that renders a single [Expense] row.
///
/// Displays the category icon (with the category color as background tint),
/// the expense description, the date, the amount, and a small auto-classified
/// badge when [Expense.autoClassified] is true.
class ExpenseListItem extends StatelessWidget {
  /// Creates an [ExpenseListItem].
  const ExpenseListItem({
    required this.expense,
    this.category,
    this.onTap,
    super.key,
  });

  /// Expense data to display.
  final Expense expense;

  /// Resolved category, or `null` when the expense is unclassified.
  final Category? category;

  /// Optional tap handler; enables list-tile ink splash when provided.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = category?.color ?? theme.colorScheme.outlineVariant;
    final icon = CategoryIconMapper.resolve(category?.icon ?? '');
    final dateLabel = DateFormat('d MMM').format(expense.date);

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: color.withAlpha(38),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        expense.description.isNotEmpty ? expense.description : '—',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        dateLabel,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (expense.autoClassified)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Tooltip(
                message: 'Auto-classified',
                child: Icon(
                  Icons.auto_awesome,
                  size: 14,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          Text(
            '€${expense.amount.toStringAsFixed(2)}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
