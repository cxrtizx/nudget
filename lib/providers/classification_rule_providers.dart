import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nudget/core/models/classification_rule.dart';
import 'package:nudget/core/repositories/i_classification_rule_repository.dart';
import 'package:nudget/providers/repository_providers.dart';

/// Notifier that owns the classification rule list.
class ClassificationRuleListNotifier
    extends AsyncNotifier<List<ClassificationRule>> {
  IClassificationRuleRepository get _repo =>
      ref.read(classificationRuleRepositoryProvider);

  @override
  Future<List<ClassificationRule>> build() =>
      ref.watch(classificationRuleRepositoryProvider).findAll();

  /// Re-fetches all rules, ordered by [ClassificationRule.matchCount] descending.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repo.findAll);
  }

  /// Deletes the rule identified by [id] and refreshes the list.
  Future<void> remove(String id) async {
    await _repo.delete(id);
    await refresh();
  }
}

/// Provides all classification rules, sorted by match count descending.
final classificationRuleListProvider =
    AsyncNotifierProvider<ClassificationRuleListNotifier,
        List<ClassificationRule>>(
  ClassificationRuleListNotifier.new,
);
