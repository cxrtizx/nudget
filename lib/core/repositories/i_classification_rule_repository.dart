import 'package:nudget/core/models/classification_rule.dart';
import 'package:nudget/core/repositories/i_repository.dart';

/// Repository contract for [ClassificationRule] persistence.
abstract class IClassificationRuleRepository
    extends IRepository<ClassificationRule> {
  /// Atomically increments [ClassificationRule.matchCount] for [ruleId].
  ///
  /// Called by [ClassificationService] each time a rule fires, keeping the
  /// most-used rules sorted to the top of the matching priority list.
  Future<void> incrementMatchCount(String ruleId);

  /// Returns all rules ordered by [ClassificationRule.matchCount] descending.
  ///
  /// Overrides [IRepository.findAll] with a guaranteed sort order required
  /// by the classification algorithm.
  @override
  Future<List<ClassificationRule>> findAll();
}
