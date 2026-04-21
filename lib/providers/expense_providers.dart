import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nudget/core/models/expense.dart';
import 'package:nudget/core/repositories/i_expense_repository.dart';
import 'package:nudget/providers/repository_providers.dart';

/// Notifier that owns the full expense list and exposes mutation methods.
class ExpenseListNotifier extends AsyncNotifier<List<Expense>> {
  IExpenseRepository get _repo => ref.read(expenseRepositoryProvider);

  @override
  Future<List<Expense>> build() =>
      ref.watch(expenseRepositoryProvider).findAll();

  /// Re-fetches the full list from the repository.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repo.findAll);
  }

  /// Persists [expense] and refreshes the list.
  Future<void> add(Expense expense) async {
    await _repo.save(expense);
    await refresh();
  }

  /// Updates [expense] in the repository and refreshes the list.
  Future<void> edit(Expense expense) async {
    await _repo.update(expense);
    await refresh();
  }

  /// Deletes the expense identified by [id] and refreshes the list.
  Future<void> remove(String id) async {
    await _repo.delete(id);
    await refresh();
  }
}

/// Provides the full list of expenses, ordered by date descending.
final expenseListProvider =
    AsyncNotifierProvider<ExpenseListNotifier, List<Expense>>(
  ExpenseListNotifier.new,
);

// ---------------------------------------------------------------------------
// Derived / scoped providers
// ---------------------------------------------------------------------------

/// Notifier for the pending (unclassified) expense list.
class UnclassifiedExpensesNotifier extends AsyncNotifier<List<Expense>> {
  @override
  Future<List<Expense>> build() =>
      ref.watch(expenseRepositoryProvider).findUnclassified();

  /// Re-fetches unclassified expenses from the repository.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      ref.read(expenseRepositoryProvider).findUnclassified,
    );
  }
}

/// Provides the list of expenses that have not yet been classified.
final unclassifiedExpensesProvider =
    AsyncNotifierProvider<UnclassifiedExpensesNotifier, List<Expense>>(
  UnclassifiedExpensesNotifier.new,
);

/// Derives the count of unclassified expenses from [unclassifiedExpensesProvider].
///
/// Drives the dashboard badge. Returns `0` during loading and on error so the
/// UI degrades gracefully.
final pendingCountProvider = Provider<int>((ref) {
  return ref.watch(unclassifiedExpensesProvider).when(
        data: (list) => list.length,
        loading: () => 0,
        error: (_, __) => 0,
      );
});

/// Returns the total euros spent in the current calendar month for [categoryId].
///
/// Derived synchronously from [expenseListProvider] so CategoryCard re-renders
/// automatically whenever the expense list changes.
final categoryMonthlySpendingProvider =
    Provider.family<double, String>((ref, categoryId) {
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month);
  final monthEnd = DateTime(now.year, now.month + 1)
      .subtract(const Duration(seconds: 1));

  return ref.watch(expenseListProvider).when(
        data: (expenses) => expenses
            .where(
              (e) =>
                  e.categoryId == categoryId &&
                  !e.date.isBefore(monthStart) &&
                  !e.date.isAfter(monthEnd),
            )
            .fold(0.0, (sum, e) => sum + e.amount),
        loading: () => 0.0,
        error: (_, __) => 0.0,
      );
});
