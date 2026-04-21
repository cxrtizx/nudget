import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nudget/providers/category_providers.dart';
import 'package:nudget/providers/expense_providers.dart';
import 'package:nudget/ui/screens/categories/create_edit_category_sheet.dart';
import 'package:nudget/ui/widgets/category_card.dart';

/// Displays all categories in a two-column grid with CRUD operations.
class CategoriesScreen extends ConsumerWidget {
  /// Creates a [CategoriesScreen].
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(message: error.toString()),
        data: (categories) {
          if (categories.isEmpty) {
            return const _EmptyView();
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(categoryListProvider.notifier).refresh(),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final spending =
                    ref.watch(categoryMonthlySpendingProvider(category.id));

                return CategoryCard(
                  key: ValueKey(category.id),
                  category: category,
                  monthlySpending: spending,
                  onEdit: () => showCreateEditCategorySheet(
                    context,
                    initialCategory: category,
                  ),
                  onDelete: () => _deleteCategory(context, ref, category.id),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showCreateEditCategorySheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add category'),
      ),
    );
  }

  Future<void> _deleteCategory(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    try {
      await ref.read(categoryListProvider.notifier).remove(id);
      // Expenses referencing this category are SET NULL by the FK cascade;
      // refresh both providers so the UI reflects the change.
      await ref.read(expenseListProvider.notifier).refresh();
      await ref.read(unclassifiedExpensesProvider.notifier).refresh();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete category: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Private state widgets
// ---------------------------------------------------------------------------

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.category_outlined,
            size: 64,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No categories yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to create your first category.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outlineVariant,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 12),
            Text(
              'Could not load categories',
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
