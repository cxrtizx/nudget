import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nudget/core/models/expense.dart';
import 'package:nudget/providers/expense_providers.dart';

/// Aggregated data for a single calendar month used by the statistics screen.
class MonthSummary {
  /// Creates a [MonthSummary].
  const MonthSummary({
    required this.year,
    required this.month,
    required this.total,
    required this.expenses,
  });

  /// Four-digit calendar year.
  final int year;

  /// Month number (1 = January … 12 = December).
  final int month;

  /// Sum of all expense amounts in this month.
  final double total;

  /// Expenses that fall within this month.
  final List<Expense> expenses;
}

/// The six most recent calendar months (oldest first), each with their
/// aggregated spending data, derived from [expenseListProvider].
///
/// The list always has exactly six entries; months with no expenses have
/// [MonthSummary.total] == 0 and an empty [MonthSummary.expenses] list.
final last6MonthsProvider = Provider<List<MonthSummary>>((ref) {
  final allExpenses =
      ref.watch(expenseListProvider).whenOrNull(data: (e) => e) ?? <Expense>[];

  final now = DateTime.now();

  return List.generate(6, (i) {
    // i=0 → five months ago; i=5 → current month.
    final offsetMonths = 5 - i;
    // Subtract months safely across year boundaries.
    final targetMonth = now.month - offsetMonths;
    final year = now.year + (targetMonth - 1) ~/ 12;
    final month = ((targetMonth - 1) % 12 + 12) % 12 + 1;

    final monthStart = DateTime(year, month);
    final monthEnd =
        DateTime(year, month + 1).subtract(const Duration(seconds: 1));

    final expenses = allExpenses
        .where(
          (e) =>
              !e.date.isBefore(monthStart) && !e.date.isAfter(monthEnd),
        )
        .toList();

    return MonthSummary(
      year: year,
      month: month,
      total: expenses.fold(0, (s, e) => s + e.amount),
      expenses: expenses,
    );
  });
});
