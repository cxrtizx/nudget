import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nudget/core/utils/category_icon_mapper.dart';
import 'package:nudget/core/utils/l10n_extension.dart';
import 'package:nudget/providers/dashboard_providers.dart';
import 'package:nudget/providers/expense_providers.dart';
import 'package:nudget/providers/period_filter_provider.dart';
import 'package:nudget/routes.dart';
import 'package:nudget/ui/widgets/all_expenses_sheet.dart';
import 'package:nudget/ui/widgets/bar_chart_widget.dart';
import 'package:nudget/ui/widgets/period_selector.dart';
import 'package:nudget/ui/widgets/pie_chart_widget.dart';

/// Main dashboard screen showing a spending summary, a chart, and a
/// per-category breakdown for the currently selected period.
class DashboardScreen extends ConsumerWidget {
  /// Creates a [DashboardScreen].
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(periodFilterProvider);
    final total = ref.watch(periodTotalProvider);
    final pendingCount = ref.watch(pendingCountProvider);
    final categoryData = ref.watch(categorySpendingProvider);
    final monthlyData = ref.watch(monthlyTotalsProvider);
    final l10n = context.l10n;

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
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settingsTitle,
            onPressed: () => context.push(kRouteSettings),
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
              onSelect: (p) =>
                  ref.read(periodFilterProvider.notifier).select(p),
            ),
            const SizedBox(height: 16),
            _SummaryCard(total: total, period: period),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                // onSectionTapped is a no-op: tapping a pie slice no longer
                // filters the list below (that list was removed).
                child: period.usesPieChart
                    ? PieChartWidget(
                        data: categoryData,
                        onSectionTapped: (_) {},
                      )
                    : BarChartWidget(
                        period: period,
                        categoryData: categoryData,
                        monthlyData: monthlyData,
                      ),
              ),
            ),
            const SizedBox(height: 16),
            _CategorySummarySection(data: categoryData),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary card
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

// ---------------------------------------------------------------------------
// Category summary section
// ---------------------------------------------------------------------------

class _CategorySummarySection extends StatelessWidget {
  const _CategorySummarySection({required this.data});

  final List<CategorySpendingData> data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.categoryBreakdown,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () => showAllExpensesSheet(context),
              child: Text(l10n.seeAll),
            ),
          ],
        ),
        if (data.isEmpty)
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
          // One card per category, already sorted by total descending.
          Column(
            children: [
              for (final item in data)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _CategoryCard(item: item),
                ),
            ],
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Individual category card
// ---------------------------------------------------------------------------

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.item});

  final CategorySpendingData item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cat = item.category;

    // ── Progress bar semantics ─────────────────────────────────────────────
    // With a spending limit: shows how much of the monthly budget is used.
    // Without a limit: shows this category's share of the period's total.
    final double progressValue;
    final String progressLabel;
    final Color progressColor;

    if (cat.spendingLimit != null) {
      final ratio = item.total / cat.spendingLimit!;
      progressValue = ratio.clamp(0.0, 1.0);
      progressLabel =
          '€${item.total.toStringAsFixed(0)} / €${cat.spendingLimit!.toStringAsFixed(0)}';
      // Color shifts to warn the user as they approach or exceed the limit.
      progressColor = ratio >= 1.0
          ? theme.colorScheme.error
          : ratio >= 0.8
              ? Colors.amber.shade700
              : cat.color;
    } else {
      progressValue = item.percentage / 100;
      progressLabel = '${item.percentage.toStringAsFixed(0)}%';
      progressColor = cat.color;
    }

    return Card(
      // Clip.hardEdge makes the left-side color block respect the card's
      // rounded corners without needing a custom painter.
      clipBehavior: Clip.hardEdge,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Left: icon block, full card height ────────────────────────
            Container(
              width: 56,
              color: cat.color.withAlpha(38),
              child: Center(
                child: Icon(
                  CategoryIconMapper.resolve(cat.icon),
                  color: cat.color,
                  size: 26,
                ),
              ),
            ),

            // ── Middle: name + progress bar ────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      cat.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: progressValue,
                      color: progressColor,
                      backgroundColor: cat.color.withAlpha(30),
                      borderRadius: BorderRadius.circular(4),
                      minHeight: 6,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      progressLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Right: amount spent ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              child: Center(
                child: Text(
                  '€${item.total.toStringAsFixed(2)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
