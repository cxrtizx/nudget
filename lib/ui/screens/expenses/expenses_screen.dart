import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nudget/core/models/category.dart';
import 'package:nudget/core/models/expense.dart';
import 'package:nudget/core/utils/l10n_extension.dart';
import 'package:nudget/providers/category_providers.dart';
import 'package:nudget/providers/expense_providers.dart';
import 'package:nudget/ui/screens/expenses/expense_detail_sheet.dart';
import 'package:nudget/ui/widgets/expense_list_item.dart';

/// Full list of expenses with category-chip and date-range filters.
///
/// Each row can be swiped left to delete or tapped to open the detail editor.
class ExpensesScreen extends ConsumerStatefulWidget {
  /// Creates an [ExpensesScreen].
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  /// `null` means "all categories".
  String? _selectedCategoryId;

  /// `null` means no date filter.
  DateTimeRange? _dateRange;

  List<Expense> _applyFilters(List<Expense> all) {
    return all.where((e) {
      if (_selectedCategoryId != null &&
          e.categoryId != _selectedCategoryId) {
        return false;
      }
      if (_dateRange != null) {
        if (e.date.isBefore(_dateRange!.start) ||
            e.date.isAfter(
              _dateRange!.end.copyWith(
                hour: 23,
                minute: 59,
                second: 59,
              ),
            )) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expenseListProvider);
    final categoriesAsync = ref.watch(categoryListProvider);
    final categories =
        categoriesAsync.whenOrNull(data: (c) => c) ?? <Category>[];
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navExpenses),
        actions: [
          if (_dateRange != null || _selectedCategoryId != null)
            IconButton(
              icon: const Icon(Icons.filter_alt_off_outlined),
              tooltip: l10n.clearFilters,
              onPressed: () => setState(() {
                _selectedCategoryId = null;
                _dateRange = null;
              }),
            ),
          IconButton(
            icon: const Icon(Icons.date_range_outlined),
            tooltip: l10n.filterByDate,
            onPressed: () => _pickDateRange(context),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_dateRange != null)
            _DateRangeBanner(
              range: _dateRange!,
              onClear: () => setState(() => _dateRange = null),
            ),

          if (categories.isNotEmpty)
            _CategoryFilterBar(
              categories: categories,
              selectedId: _selectedCategoryId,
              onSelected: (id) =>
                  setState(() => _selectedCategoryId = id),
            ),

          Expanded(
            child: expensesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, _) => _ErrorView(message: err.toString()),
              data: (all) {
                final expenses = _applyFilters(all);
                if (expenses.isEmpty) {
                  return _EmptyView(
                    isFiltered:
                        _selectedCategoryId != null || _dateRange != null,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(expenseListProvider.notifier).refresh(),
                  child: ListView.separated(
                    itemCount: expenses.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 72),
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      final category = ref.watch(
                        categoryByIdProvider(expense.categoryId ?? ''),
                      );
                      return _DismissibleExpenseRow(
                        expense: expense,
                        category: category,
                        onDismissed: () => _deleteExpense(expense.id),
                        onTap: () => _openDetail(context, expense),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
      initialDateRange: _dateRange,
    );
    if (picked != null) setState(() => _dateRange = picked);
  }

  Future<void> _openDetail(BuildContext context, Expense expense) async {
    await showExpenseDetailSheet(context, expense: expense);
  }

  Future<void> _deleteExpense(String id) async {
    try {
      await ref.read(expenseListProvider.notifier).remove(id);
      await ref.read(unclassifiedExpensesProvider.notifier).refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.failedToDelete(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _DismissibleExpenseRow extends StatelessWidget {
  const _DismissibleExpenseRow({
    required this.expense,
    required this.category,
    required this.onDismissed,
    required this.onTap,
  });

  final Expense expense;
  final Category? category;
  final VoidCallback onDismissed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: theme.colorScheme.errorContainer,
        child: Icon(
          Icons.delete_outline,
          color: theme.colorScheme.onErrorContainer,
        ),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => onDismissed(),
      child: ExpenseListItem(
        expense: expense,
        category: category,
        onTap: onTap,
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final l10n = context.l10n;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteExpenseTitle),
        content: Text(l10n.cannotBeUndone),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<Category> categories;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      height: 48,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: FilterChip(
              label: Text(l10n.allFilter),
              selected: selectedId == null,
              onSelected: (_) => onSelected(null),
            ),
          ),
          ...categories.map(
            (c) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: FilterChip(
                avatar: Icon(
                  Icons.circle,
                  size: 10,
                  color: c.color,
                ),
                label: Text(c.name),
                selected: selectedId == c.id,
                onSelected: (_) =>
                    onSelected(selectedId == c.id ? null : c.id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateRangeBanner extends StatelessWidget {
  const _DateRangeBanner({required this.range, required this.onClear});

  final DateTimeRange range;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = DateFormat('d MMM yyyy');
    return Container(
      width: double.infinity,
      color: theme.colorScheme.secondaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(
            Icons.date_range,
            size: 16,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${fmt.format(range.start)} – ${fmt.format(range.end)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: onClear,
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.isFiltered});

  final bool isFiltered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFiltered
                ? Icons.search_off_outlined
                : Icons.receipt_long_outlined,
            size: 64,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            isFiltered ? l10n.noExpensesMatchFilter : l10n.noExpensesYet,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (isFiltered) ...[
            const SizedBox(height: 8),
            Text(
              l10n.tryAdjustingFilter,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outlineVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(
              l10n.couldNotLoadExpenses,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
