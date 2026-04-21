import 'dart:async';

import 'package:nudget/core/models/classification_rule.dart';
import 'package:nudget/core/models/expense.dart';
import 'package:nudget/core/repositories/i_classification_rule_repository.dart';
import 'package:nudget/core/repositories/i_expense_repository.dart';
import 'package:nudget/core/utils/logger.dart';
import 'package:uuid/uuid.dart';

/// Applies [ClassificationRule] patterns to [Expense] entries and manages the
/// rule lifecycle.
///
/// Rules are sorted by [ClassificationRule.matchCount] descending so the most
/// frequently matched rules are tested first, minimising average scan time.
///
/// Exposes a [pendingCount] broadcast stream that emits the current number of
/// unclassified expenses after every operation that may change it.
class ClassificationService {
  /// Creates a [ClassificationService].
  ClassificationService({
    required IClassificationRuleRepository rulesRepository,
    required IExpenseRepository expenseRepository,
  })  : _rulesRepo = rulesRepository,
        _expenseRepo = expenseRepository {
    // Emit an initial count so subscribers get a value immediately.
    _refreshPendingCount();
  }

  final IClassificationRuleRepository _rulesRepo;
  final IExpenseRepository _expenseRepo;
  static const Logger _log = Logger('ClassificationService');
  static const Uuid _uuid = Uuid();

  final StreamController<int> _pendingController =
      StreamController<int>.broadcast();

  /// Broadcasts the number of unclassified expenses whenever it changes.
  ///
  /// Used by the dashboard badge and the pending screen counter. The stream
  /// emits an initial value immediately after construction.
  Stream<int> get pendingCount => _pendingController.stream;

  // ---------------------------------------------------------------------------
  // Classification
  // ---------------------------------------------------------------------------

  /// Classifies [expense] against all stored rules and persists it.
  ///
  /// If a rule matches, [Expense.categoryId] and [Expense.autoClassified] are
  /// set on the saved record and the rule's [ClassificationRule.matchCount] is
  /// incremented.
  ///
  /// Returns the saved expense (classified or unclassified).
  Future<Expense> classify(Expense expense) async {
    final rules = await _rulesRepo.findAll(); // already sorted by matchCount ↓
    Expense toSave = expense;

    for (final rule in rules) {
      final regex = RegExp(
        rule.pattern,
        caseSensitive: false,
        unicode: true,
      );
      if (regex.hasMatch(expense.description)) {
        _log.info(
          'Rule "${rule.pattern}" matched expense "${expense.description}"',
        );
        toSave = expense.copyWith(
          categoryId: rule.categoryId,
          autoClassified: true,
        );
        await _expenseRepo.save(toSave);
        await _rulesRepo.incrementMatchCount(rule.id);
        await _refreshPendingCount();
        return toSave;
      }
    }

    // No rule matched — save as unclassified pending manual review.
    await _expenseRepo.save(toSave);
    await _refreshPendingCount();
    return toSave;
  }

  // ---------------------------------------------------------------------------
  // Rule management
  // ---------------------------------------------------------------------------

  /// Returns all rules ordered by [ClassificationRule.matchCount] descending.
  Future<List<ClassificationRule>> listRules() => _rulesRepo.findAll();

  /// Deletes the rule identified by [id].
  Future<void> deleteRule(String id) async {
    await _rulesRepo.delete(id);
    _log.info('Deleted rule $id');
  }

  /// Returns `true` if [pattern] (compiled case-insensitively) matches [text].
  ///
  /// Intended for a future rule-preview UI that lets users test patterns before
  /// saving them.
  bool testRule(String pattern, String text) {
    try {
      return RegExp(pattern, caseSensitive: false, unicode: true).hasMatch(text);
    } catch (_) {
      // Invalid regex — treat as no match rather than crashing.
      return false;
    }
  }

  /// Creates a [ClassificationRule] from the key term in [description] and
  /// assigns [categoryId] to all future matching expenses.
  ///
  /// When [applyToExisting] is `true`, the rule is also applied retroactively
  /// to all currently unclassified expenses that match.
  Future<ClassificationRule> createRuleFromDescription({
    required String description,
    required String categoryId,
    bool applyToExisting = false,
  }) async {
    final pattern = _extractKeyTerm(description);
    final rule = ClassificationRule(
      id: _uuid.v4(),
      pattern: pattern,
      categoryId: categoryId,
      createdAt: DateTime.now().toUtc(),
      matchCount: 0,
    );
    await _rulesRepo.save(rule);
    _log.info('Created rule "$pattern" → category $categoryId');

    if (applyToExisting) {
      await _applyRuleRetroactively(rule);
    }

    return rule;
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Applies [rule] to all currently unclassified expenses that match its
  /// pattern, updating them in the repository.
  Future<void> _applyRuleRetroactively(ClassificationRule rule) async {
    final unclassified = await _expenseRepo.findUnclassified();
    final regex = RegExp(rule.pattern, caseSensitive: false, unicode: true);
    var matchCount = 0;

    for (final expense in unclassified) {
      if (regex.hasMatch(expense.description)) {
        await _expenseRepo.update(
          expense.copyWith(
            categoryId: rule.categoryId,
            autoClassified: true,
          ),
        );
        matchCount++;
      }
    }

    if (matchCount > 0) {
      // Bulk-increment matchCount for every retroactive application.
      for (var i = 0; i < matchCount; i++) {
        await _rulesRepo.incrementMatchCount(rule.id);
      }
      _log.info('Retroactively applied rule to $matchCount expenses');
    }

    _refreshPendingCount();
  }

  /// Pulls the simplest meaningful token from [description] to use as a regex
  /// pattern — the longest word that is not a stop-word.
  String _extractKeyTerm(String description) {
    const stopWords = {'de', 'en', 'el', 'la', 'los', 'las', 'un', 'una'};
    final words = description
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2 && !stopWords.contains(w.toLowerCase()))
        .toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    // Fall back to the full description if no meaningful word is found.
    return words.isNotEmpty ? words.first : description;
  }

  Future<void> _refreshPendingCount() async {
    try {
      final unclassified = await _expenseRepo.findUnclassified();
      _pendingController.add(unclassified.length);
    } catch (e, st) {
      _log.error('Failed to refresh pending count', e, st);
    }
  }

  /// Closes the internal stream controller. Call this when the service is no
  /// longer needed (handled automatically via [classificationServiceProvider]).
  void dispose() => _pendingController.close();
}
