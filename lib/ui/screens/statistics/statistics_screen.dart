import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nudget/core/models/category.dart';
import 'package:nudget/core/models/expense.dart';
import 'package:nudget/core/utils/l10n_extension.dart';
import 'package:nudget/providers/category_providers.dart';
import 'package:nudget/providers/dashboard_providers.dart';
import 'package:nudget/providers/statistics_providers.dart';
import 'package:nudget/ui/widgets/language_selector_dialog.dart';

/// Displays a month-over-month bar chart for the last six months and a
/// per-category spending breakdown for the selected month.
class StatisticsScreen extends ConsumerStatefulWidget {
  /// Creates a [StatisticsScreen].
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  /// Index into [last6MonthsProvider] of the month currently shown below
  /// the chart. Defaults to the current (most recent) month.
  int _selectedIndex = 5;

  @override
  Widget build(BuildContext context) {
    final months = ref.watch(last6MonthsProvider);
    final categories =
        ref.watch(categoryListProvider).whenOrNull(data: (c) => c) ??
            <Category>[];
    final l10n = context.l10n;

    final selected = months[_selectedIndex];
    final breakdown = _computeBreakdown(selected.expenses, categories);
    final top3 = breakdown.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statisticsTitle),
        actions: [
          // Language selector — accessible from here as a settings-like action.
          IconButton(
            icon: const Icon(Icons.translate),
            tooltip: l10n.language,
            onPressed: () => showLanguageSelectorSheet(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Text(
            l10n.last6Months,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
              child: _SixMonthBarChart(
                months: months,
                selectedIndex: _selectedIndex,
                onMonthSelected: (i) => setState(() => _selectedIndex = i),
              ),
            ),
          ),
          const SizedBox(height: 20),

          _MonthHeader(summary: selected),
          const SizedBox(height: 16),

          if (top3.isNotEmpty) ...[
            Text(
              l10n.topCategories,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            _Top3Section(top3: top3),
            const SizedBox(height: 20),
          ],

          if (breakdown.isNotEmpty) ...[
            Text(
              l10n.categoryBreakdown,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            _CategoryBreakdownList(items: breakdown),
          ],

          if (breakdown.isEmpty && selected.total == 0)
            const _EmptyMonthView(),
        ],
      ),
    );
  }

  List<CategorySpendingData> _computeBreakdown(
    List<Expense> expenses,
    List<Category> categories,
  ) {
    if (expenses.isEmpty) return [];

    final totalsById = <String, double>{};
    for (final e in expenses) {
      if (e.categoryId == null) continue;
      totalsById[e.categoryId!] =
          (totalsById[e.categoryId!] ?? 0) + e.amount;
    }

    final grandTotal = totalsById.values.fold<double>(0, (a, b) => a + b);
    if (grandTotal == 0) return [];

    final result = <CategorySpendingData>[];
    for (final cat in categories) {
      final total = totalsById[cat.id] ?? 0;
      if (total > 0) {
        result.add(
          CategorySpendingData(
            category: cat,
            total: total,
            percentage: total / grandTotal * 100,
          ),
        );
      }
    }
    result.sort((a, b) => b.total.compareTo(a.total));
    return result;
  }
}

// ---------------------------------------------------------------------------
// 6-month bar chart
// ---------------------------------------------------------------------------

class _SixMonthBarChart extends StatelessWidget {
  const _SixMonthBarChart({
    required this.months,
    required this.selectedIndex,
    required this.onMonthSelected,
  });

  final List<MonthSummary> months;
  final int selectedIndex;
  final ValueChanged<int> onMonthSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final maxY = months
        .map((m) => m.total)
        .fold<double>(0, (prev, t) => t > prev ? t : prev);

    if (maxY == 0) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Text(
            l10n.noSpendingData,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: maxY * 1.25,
          barGroups: months.asMap().entries.map((entry) {
            final i = entry.key;
            final m = entry.value;
            final isSelected = i == selectedIndex;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: m.total,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primaryContainer,
                  width: isSelected ? 22 : 16,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => theme.colorScheme.inverseSurface,
              getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                '€${rod.toY.toStringAsFixed(2)}',
                TextStyle(
                  color: theme.colorScheme.onInverseSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            touchCallback: (event, response) {
              if (event.isInterestedForInteractions &&
                  response?.spot != null) {
                onMonthSelected(response!.spot!.touchedBarGroupIndex);
              }
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, _) {
                  final i = value.toInt();
                  if (i < 0 || i >= months.length) {
                    return const SizedBox.shrink();
                  }
                  final m = months[i];
                  final label = DateFormat('MMM').format(
                    DateTime(m.year, m.month),
                  );
                  final isSelected = i == selectedIndex;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: theme.colorScheme.outlineVariant.withAlpha(80),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
        ),
        swapAnimationDuration: const Duration(milliseconds: 250),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Selected month header
// ---------------------------------------------------------------------------

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({required this.summary});

  final MonthSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final monthLabel = DateFormat('MMMM yyyy').format(
      DateTime(summary.year, summary.month),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          monthLabel,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '€${summary.total.toStringAsFixed(2)}',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            // expenseCount uses ICU plural rules: "1 expense" vs "3 expenses"
            // (or the locale-correct equivalent in ES/GL).
            Text(
              l10n.expenseCount(summary.expenses.length),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Top 3 categories
// ---------------------------------------------------------------------------

class _Top3Section extends StatelessWidget {
  const _Top3Section({required this.top3});

  final List<CategorySpendingData> top3;

  static const _medals = ['🥇', '🥈', '🥉'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Column(
        children: top3.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return ListTile(
            leading: Text(
              _medals[i],
              style: const TextStyle(fontSize: 22),
            ),
            title: Text(item.category.name),
            subtitle: LinearProgressIndicator(
              value: item.percentage / 100,
              color: item.category.color,
              backgroundColor: item.category.color.withAlpha(38),
              borderRadius: BorderRadius.circular(4),
              minHeight: 6,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '€${item.total.toStringAsFixed(2)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${item.percentage.toStringAsFixed(1)}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Full category breakdown list
// ---------------------------------------------------------------------------

class _CategoryBreakdownList extends StatelessWidget {
  const _CategoryBreakdownList({required this.items});

  final List<CategorySpendingData> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 16),
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: item.category.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.category.name,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '€${item.total.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '${item.percentage.toStringAsFixed(0)}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: item.percentage / 100,
                  color: item.category.color,
                  backgroundColor: item.category.color.withAlpha(30),
                  borderRadius: BorderRadius.circular(4),
                  minHeight: 5,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyMonthView extends StatelessWidget {
  const _EmptyMonthView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(
            Icons.insert_chart_outlined,
            size: 56,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.noExpensesThisMonth,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
