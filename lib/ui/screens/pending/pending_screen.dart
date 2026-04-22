import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nudget/core/models/category.dart';
import 'package:nudget/core/models/expense.dart';
import 'package:nudget/core/utils/category_icon_mapper.dart';
import 'package:nudget/core/utils/l10n_extension.dart';
import 'package:nudget/providers/category_providers.dart';
import 'package:nudget/providers/classification_service_provider.dart';
import 'package:nudget/providers/expense_providers.dart';

/// Lists all unclassified expenses and lets the user assign a category,
/// optionally creating a persistent matching rule for future expenses.
class PendingScreen extends ConsumerStatefulWidget {
  /// Creates a [PendingScreen].
  const PendingScreen({super.key});

  @override
  ConsumerState<PendingScreen> createState() => _PendingScreenState();
}

class _PendingScreenState extends ConsumerState<PendingScreen> {
  /// Tracks the category the user has chosen for each expense (by id).
  final Map<String, String?> _selectedCategories = {};

  /// Controls the "Remember for similar expenses" toggle per expense.
  final Map<String, bool> _createRule = {};

  /// Expense ids currently being saved to prevent double-taps.
  final Set<String> _processing = {};

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(unclassifiedExpensesProvider);
    final categories =
        ref.watch(categoryListProvider).whenOrNull(data: (c) => c) ??
            <Category>[];
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pendingClassification),
      ),
      body: expensesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _ErrorView(message: err.toString()),
        data: (expenses) {
          if (expenses.isEmpty) return const _EmptyView();
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(unclassifiedExpensesProvider.notifier).refresh(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: expenses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return _PendingExpenseCard(
                  expense: expense,
                  categories: categories,
                  selectedCategoryId: _selectedCategories[expense.id],
                  createRule: _createRule[expense.id] ?? false,
                  isProcessing: _processing.contains(expense.id),
                  onCategoryChanged: (id) =>
                      setState(() => _selectedCategories[expense.id] = id),
                  onCreateRuleChanged: (v) =>
                      setState(() => _createRule[expense.id] = v),
                  onClassify: () => _classify(expense),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _classify(Expense expense) async {
    final categoryId = _selectedCategories[expense.id];
    if (categoryId == null) return;

    setState(() => _processing.add(expense.id));
    try {
      final shouldCreateRule = _createRule[expense.id] ?? false;

      await ref.read(expenseListProvider.notifier).edit(
            expense.copyWith(
              categoryId: categoryId,
              autoClassified: false,
            ),
          );

      if (shouldCreateRule) {
        await ref
            .read(classificationServiceProvider)
            .createRuleFromDescription(
              description: expense.description,
              categoryId: categoryId,
              applyToExisting: true,
            );
      }

      await ref.read(unclassifiedExpensesProvider.notifier).refresh();
      await ref.read(expenseListProvider.notifier).refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.failedToClassify(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _processing.remove(expense.id));
    }
  }
}

// ---------------------------------------------------------------------------
// Card widget
// ---------------------------------------------------------------------------

class _PendingExpenseCard extends StatelessWidget {
  const _PendingExpenseCard({
    required this.expense,
    required this.categories,
    required this.selectedCategoryId,
    required this.createRule,
    required this.isProcessing,
    required this.onCategoryChanged,
    required this.onCreateRuleChanged,
    required this.onClassify,
  });

  final Expense expense;
  final List<Category> categories;
  final String? selectedCategoryId;
  final bool createRule;
  final bool isProcessing;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<bool> onCreateRuleChanged;
  final VoidCallback onClassify;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '€${expense.amount.toStringAsFixed(2)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (expense.description.isNotEmpty)
                        Text(
                          expense.description,
                          style: theme.textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(
                    expense.notificationSource,
                    style: theme.textTheme.labelSmall,
                  ),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),

            if (expense.rawNotificationText.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  expense.rawNotificationText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            _CategorySelector(
              categories: categories,
              selectedId: selectedCategoryId,
              onChanged: onCategoryChanged,
            ),

            if (selectedCategoryId != null) ...[
              const SizedBox(height: 8),
              _RuleToggle(
                value: createRule,
                onChanged: onCreateRuleChanged,
              ),
            ],

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: isProcessing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(
                  createRule && selectedCategoryId != null
                      ? l10n.classifyAndSaveRule
                      : l10n.classify,
                ),
                onPressed:
                    (isProcessing || selectedCategoryId == null)
                        ? null
                        : onClassify,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Category selector — horizontal scrollable chips
// ---------------------------------------------------------------------------

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.categories,
    required this.selectedId,
    required this.onChanged,
  });

  final List<Category> categories;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.assignCategory,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: categories.map((c) {
              final selected = selectedId == c.id;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  avatar: Icon(
                    CategoryIconMapper.resolve(c.icon),
                    size: 16,
                    color: selected
                        ? Theme.of(context).colorScheme.onSecondaryContainer
                        : c.color,
                  ),
                  label: Text(c.name),
                  selected: selected,
                  onSelected: (_) =>
                      onChanged(selected ? null : c.id),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Rule creation toggle
// ---------------------------------------------------------------------------

class _RuleToggle extends StatelessWidget {
  const _RuleToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Switch(value: value, onChanged: onChanged),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.rememberForSimilar,
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    l10n.rememberForSimilarDesc,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// State views
// ---------------------------------------------------------------------------

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 72,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.allCaughtUp,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noPendingExpenses,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
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
            Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.couldNotLoadPendingExpenses,
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
