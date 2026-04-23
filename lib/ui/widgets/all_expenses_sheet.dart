import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nudget/core/models/expense.dart';
import 'package:nudget/core/utils/l10n_extension.dart';
import 'package:nudget/providers/category_providers.dart';
import 'package:nudget/providers/expense_providers.dart';
import 'package:nudget/ui/screens/expenses/expense_detail_sheet.dart';
import 'package:nudget/ui/widgets/expense_list_item.dart';

/// Opens a bottom sheet with the full, unfiltered list of expenses.
///
/// Uses [ListView.builder] which constructs only the visible rows on demand,
/// so there is no need for client-side pagination even with thousands of items.
Future<void> showAllExpensesSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _AllExpensesSheet(),
    );

// ---------------------------------------------------------------------------
// Sheet widget
// ---------------------------------------------------------------------------

class _AllExpensesSheet extends ConsumerWidget {
  const _AllExpensesSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expenseListProvider);
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.92,
      minChildSize: 0.5,
      builder: (context, scrollController) => Column(
        children: [
          // ── Drag handle ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Title ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.allExpenses,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const Divider(height: 1),

          // ── List ────────────────────────────────────────────────────────
          Expanded(
            child: expensesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    err.toString(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              data: (expenses) {
                if (expenses.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.noExpensesYet,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                // ListView.builder only builds the widgets currently visible
                // on screen (plus a small off-screen buffer). With 1000+
                // expenses Flutter still only creates ~15 widgets at a time.
                return ListView.separated(
                  controller: scrollController,
                  itemCount: expenses.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 72),
                  itemBuilder: (context, index) =>
                      _ExpenseRow(expense: expenses[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Single expense row — resolves its own category
// ---------------------------------------------------------------------------

class _ExpenseRow extends ConsumerWidget {
  const _ExpenseRow({required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(
      categoryByIdProvider(expense.categoryId ?? ''),
    );
    return ExpenseListItem(
      expense: expense,
      category: category,
      onTap: () => showExpenseDetailSheet(context, expense: expense),
    );
  }
}
