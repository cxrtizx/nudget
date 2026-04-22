import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nudget/core/models/expense.dart';
import 'package:nudget/core/utils/l10n_extension.dart';
import 'package:nudget/providers/category_providers.dart';
import 'package:nudget/providers/dashboard_providers.dart';
import 'package:nudget/providers/expense_providers.dart';
import 'package:nudget/providers/period_filter_provider.dart';
import 'package:nudget/routes.dart';
import 'package:nudget/ui/widgets/all_expenses_sheet.dart';
import 'package:nudget/ui/widgets/bar_chart_widget.dart';
import 'package:nudget/ui/widgets/expense_list_item.dart';
import 'package:nudget/ui/widgets/period_selector.dart';
import 'package:nudget/ui/widgets/pie_chart_widget.dart';

/// Main dashboard screen showing a spending summary, a chart, and recent
/// expenses for the currently selected period.
class DashboardScreen extends ConsumerStatefulWidget {
  /// Creates a [DashboardScreen].
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  /// Category id currently highlighted via a pie-chart tap, or `null`.
  String? _highlightedCategoryId;

  @override
  Widget build(BuildContext context) {
    final period = ref.watch(periodFilterProvider);
    final total = ref.watch(periodTotalProvider);
    final pendingCount = ref.watch(pendingCountProvider);
    final categoryData = ref.watch(categorySpendingProvider);
    final monthlyData = ref.watch(monthlyTotalsProvider);
    final recentExpenses = ref.watch(recentExpensesProvider);
    final l10n = context.l10n;

    final filteredExpenses = _highlightedCategoryId != null
        ? recentExpenses
            .where((e) => e.categoryId == _highlightedCategoryId)
            .toList()
        : recentExpenses;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          if (pendingCount > 0)
            Badge.count(
              count: pendingCount,
              child: IconButton(
                icon: const Icon(Icons.pending_actions_outlined),
                tooltip: l10n.pendingClassificationTooltip,
                onPressed: () => context.push(kRoutePending),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(expenseListProvider.notifier).refresh();
          await ref.read(unclassifiedExpensesProvider.notifier).refresh();
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            PeriodSelector(
              selected: period,
              onSelect: (p) {
                ref.read(periodFilterProvider.notifier).select(p);
                setState(() => _highlightedCategoryId = null);
              },
            ),
            const SizedBox(height: 16),
            _SummaryCard(total: total, period: period),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: period.usesPieChart
                    ? PieChartWidget(
                        data: categoryData,
                        onSectionTapped: (id) =>
                            setState(() => _highlightedCategoryId = id),
                      )
                    : BarChartWidget(
                        period: period,
                        categoryData: categoryData,
                        monthlyData: monthlyData,
                      ),
              ),
            ),
            const SizedBox(height: 16),
            _RecentExpensesSection(
              expenses: filteredExpenses,
              isFiltered: _highlightedCategoryId != null,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.total, required this.period});

  final double total;
  final DashboardPeriod period;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // spentThisPeriod takes the period name as a parameter so
                    // the sentence is translated as a whole unit — not
                    // assembled from fragments, which breaks in many languages.
                    l10n.spentThisPeriod(
                      period.localizedLabel(l10n).toLowerCase(),
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '€${total.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 40,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentExpensesSection extends ConsumerWidget {
  const _RecentExpensesSection({
    required this.expenses,
    required this.isFiltered,
  });

  final List<Expense> expenses;
  final bool isFiltered;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isFiltered ? l10n.filteredExpenses : l10n.recentExpenses,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            TextButton(
              onPressed: () => showAllExpensesSheet(context),
              child: Text(l10n.seeAll),
            ),
          ],
        ),
        if (expenses.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                l10n.noExpensesYet,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: expenses.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 56),
              itemBuilder: (context, index) {
                final expense = expenses[index];
                final category = ref.watch(
                  categoryByIdProvider(expense.categoryId ?? ''),
                );
                return ExpenseListItem(expense: expense, category: category);
              },
            ),
          ),
      ],
    );
  }
}
