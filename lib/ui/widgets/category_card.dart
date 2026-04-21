import 'package:flutter/material.dart';
import 'package:nudget/core/models/category.dart';
import 'package:nudget/core/utils/category_icon_mapper.dart';

/// A card representing a single [Category] in the categories grid.
///
/// Displays the category icon, name, monthly spending total, and an optional
/// spending-limit progress bar. Supports long-press to surface edit/delete
/// actions via a modal bottom sheet.
class CategoryCard extends StatelessWidget {
  /// Creates a [CategoryCard].
  const CategoryCard({
    required this.category,
    required this.monthlySpending,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  /// The category this card represents.
  final Category category;

  /// Total euros spent in the current month for this category.
  final double monthlySpending;

  /// Called when the user chooses "Edit" from the long-press menu.
  final VoidCallback onEdit;

  /// Called when the user confirms deletion.
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: '${category.name} category card. '
          'Monthly spending: ${monthlySpending.toStringAsFixed(2)} euros.',
      button: true,
      child: GestureDetector(
        onLongPress: () => _showOptionsSheet(context),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _CategoryIcon(category: category),
                    const Spacer(),
                    if (category.spendingLimit != null)
                      _LimitBadge(
                        spending: monthlySpending,
                        limit: category.spendingLimit!,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  category.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '€${monthlySpending.toStringAsFixed(2)} this month',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (category.spendingLimit != null) ...[
                  const SizedBox(height: 10),
                  _SpendingProgressBar(
                    spending: monthlySpending,
                    limit: category.spendingLimit!,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOptionsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit category'),
              onTap: () {
                Navigator.of(ctx).pop();
                onEdit();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(ctx).colorScheme.error,
              ),
              title: Text(
                'Delete category',
                style: TextStyle(
                  color: Theme.of(ctx).colorScheme.error,
                ),
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                _confirmDelete(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete category'),
        content: Text(
          'Delete "${category.name}"? Expenses in this category will '
          'become unclassified.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () {
              Navigator.of(ctx).pop(true);
              onDelete();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.category});
  final Category category;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        CategoryIconMapper.resolve(category.icon),
        color: category.color,
        size: 24,
      ),
    );
  }
}

class _LimitBadge extends StatelessWidget {
  const _LimitBadge({required this.spending, required this.limit});
  final double spending;
  final double limit;

  @override
  Widget build(BuildContext context) {
    final pct = (spending / limit).clamp(0.0, double.infinity);
    final color = _progressColor(pct, Theme.of(context).colorScheme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '€${limit.toStringAsFixed(0)} limit',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _SpendingProgressBar extends StatelessWidget {
  const _SpendingProgressBar({required this.spending, required this.limit});
  final double spending;
  final double limit;

  @override
  Widget build(BuildContext context) {
    final pct = (spending / limit).clamp(0.0, 1.0);
    final colorScheme = Theme.of(context).colorScheme;
    final color = _progressColor(pct, colorScheme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 6,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(pct * 100).toStringAsFixed(0)}% of €${limit.toStringAsFixed(0)}',
          style: TextStyle(fontSize: 10, color: color),
        ),
      ],
    );
  }
}

/// Maps a spending ratio to a semantic color:
/// < 75 % → green, 75–90 % → amber, ≥ 90 % → red.
Color _progressColor(double pct, ColorScheme scheme) {
  if (pct >= 0.9) return scheme.error;
  if (pct >= 0.75) return const Color(0xFFFF9800); // Orange / amber
  return const Color(0xFF4CAF50); // Green
}
