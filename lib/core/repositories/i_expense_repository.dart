import 'package:nudget/core/models/expense.dart';
import 'package:nudget/core/repositories/i_repository.dart';

/// Repository contract for [Expense] persistence.
///
/// Extends [IRepository] with expense-specific query methods used by
/// [ClassificationService] and the dashboard/statistics providers.
abstract class IExpenseRepository extends IRepository<Expense> {
  /// Returns all expenses whose [Expense.date] falls within [[from], [to]]
  /// (inclusive), ordered by date descending.
  Future<List<Expense>> findByDateRange(DateTime from, DateTime to);

  /// Returns all expenses where [Expense.categoryId] is `null`.
  ///
  /// Used to populate the pending classification screen and the dashboard badge.
  Future<List<Expense>> findUnclassified();

  /// Returns all expenses assigned to [categoryId], ordered by date descending.
  Future<List<Expense>> findByCategoryId(String categoryId);
}
