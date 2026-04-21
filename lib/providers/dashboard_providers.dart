import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nudget/core/models/category.dart';
import 'package:nudget/core/models/expense.dart';
import 'package:nudget/providers/category_providers.dart';
import 'package:nudget/providers/expense_providers.dart';
import 'package:nudget/providers/period_filter_provider.dart';

/// Aggregated spending data for a single category used by [PieChartWidget]
/// and [BarChartWidget] in month mode.
class CategorySpendingData {
  /// Creates a [CategorySpendingData].
  const CategorySpendingData({
    required this.category,
    required this.total,
    required this.percentage,
  });

  /// The category these expenses belong to.
  final Category category;

  /// Total euros spent in this category for the active period.
  final double total;

  /// Fraction of the period total, expressed as a percentage (0–100).
  final double percentage;
}

/// Total spending for a single calendar month, used by [BarChartWidget]
/// in year mode.
class MonthlyTotalData {
  /// Creates a [MonthlyTotalData].
  const MonthlyTotalData({required this.month, required this.total});

  /// Month number (1 = January … 12 = December).
  final int month;

  /// Total euros spent in this month.
  final double total;
}

// ---------------------------------------------------------------------------
// Period-scoped expense slice
// ---------------------------------------------------------------------------

/// All expenses whose [Expense.date] falls within the active date range.
///
/// Returns an empty list while loading or on error so charts degrade gracefully.
final periodExpensesProvider = Provider<List<Expense>>((ref) {
  final range = ref.watch(activeDateRangeProvider);
  return ref.watch(expenseListProvider).when(
        data: (expenses) => expenses
            .where(
              (e) =>
                  !e.date.isBefore(range.from) && !e.date.isAfter(range.to),
            )
            .toList(),
        loading: () => [],
        error: (_, __) => [],
      );
});

/// Sum of all [Expense.amount] values in the active period.
final periodTotalProvider = Provider<double>((ref) {
  return ref
      .watch(periodExpensesProvider)
      .fold(0.0, (sum, e) => sum + e.amount);
});

// ---------------------------------------------------------------------------
// Chart data providers
// ---------------------------------------------------------------------------

/// Per-category spending breakdown for the active period, sorted by total
/// descending. Used by [PieChartWidget] and [BarChartWidget] (month mode).
///
/// Expenses with no category are excluded from the breakdown.
final categorySpendingProvider = Provider<List<CategorySpendingData>>((ref) {
  final expenses = ref.watch(periodExpensesProvider);
  final categories =
      ref.watch(categoryListProvider).whenOrNull(data: (c) => c) ?? [];

  if (expenses.isEmpty) return [];

  final totalsById = <String, double>{};
  for (final e in expenses) {
    if (e.categoryId == null) continue;
    totalsById[e.categoryId!] =
        (totalsById[e.categoryId!] ?? 0.0) + e.amount;
  }

  final grandTotal = totalsById.values.fold(0.0, (a, b) => a + b);
  if (grandTotal == 0) return [];

  final result = <CategorySpendingData>[];
  for (final cat in categories) {
    final total = totalsById[cat.id] ?? 0.0;
    if (total > 0) {
      result.add(
        CategorySpendingData(
          category: cat,
          total: total,
          percentage: total / grandTotal * 100,
        ),
      );
    }
  }

  result.sort((a, b) => b.total.compareTo(a.total));
  return result;
});

/// One [MonthlyTotalData] per month of the year for the active period.
///
/// Always returns 12 entries (January–December); months with no data have
/// [MonthlyTotalData.total] == 0. Used by [BarChartWidget] in year mode.
final monthlyTotalsProvider = Provider<List<MonthlyTotalData>>((ref) {
  final expenses = ref.watch(periodExpensesProvider);
  final totals = <int, double>{};
  for (final e in expenses) {
    final m = e.date.month;
    totals[m] = (totals[m] ?? 0.0) + e.amount;
  }
  return List.generate(
    12,
    (i) => MonthlyTotalData(month: i + 1, total: totals[i + 1] ?? 0.0),
  );
});

// ---------------------------------------------------------------------------
// Recent expenses
// ---------------------------------------------------------------------------

/// The five most recent expenses across all periods and categories.
///
/// Sorted by [Expense.date] descending.
final recentExpensesProvider = Provider<List<Expense>>((ref) {
  return ref.watch(expenseListProvider).when(
        data: (expenses) {
          final sorted = [...expenses]
            ..sort((a, b) => b.date.compareTo(a.date));
          return sorted.take(5).toList();
        },
        loading: () => [],
        error: (_, __) => [],
      );
});
