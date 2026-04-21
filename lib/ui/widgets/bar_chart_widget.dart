import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:nudget/providers/dashboard_providers.dart';
import 'package:nudget/providers/period_filter_provider.dart';

/// Bar chart used for [DashboardPeriod.month] and [DashboardPeriod.year].
///
/// - **Month**: one bar per category, coloured with the category colour.
/// - **Year**: one bar per calendar month, coloured with the primary theme
///   colour.
///
/// Tapping a bar shows a tooltip with the exact euro amount.
class BarChartWidget extends StatefulWidget {
  /// Creates a [BarChartWidget].
  const BarChartWidget({
    required this.period,
    required this.categoryData,
    required this.monthlyData,
    super.key,
  });

  /// Determines which dataset to render.
  final DashboardPeriod period;

  /// Category breakdown — used when [period] is [DashboardPeriod.month].
  final List<CategorySpendingData> categoryData;

  /// Monthly totals — used when [period] is [DashboardPeriod.year].
  final List<MonthlyTotalData> monthlyData;

  @override
  State<BarChartWidget> createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<BarChartWidget> {
  int? _touchedIndex;

  bool get _isMonthMode => widget.period == DashboardPeriod.month;

  bool get _isEmpty => _isMonthMode
      ? widget.categoryData.isEmpty
      : widget.monthlyData.every((m) => m.total == 0);

  @override
  Widget build(BuildContext context) {
    if (_isEmpty) return _EmptyState(period: widget.period);

    final theme = Theme.of(context);
    final groups =
        _isMonthMode ? _categoryGroups(theme) : _monthGroups(theme);

    final maxY = groups
        .expand((g) => g.barRods.map((r) => r.toY))
        .fold<double>(0, (prev, y) => y > prev ? y : prev);

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: maxY * 1.25,
          barGroups: groups,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => theme.colorScheme.inverseSurface,
              getTooltipItem: (_, __, rod, ___) => BarTooltipItem(
                '€${rod.toY.toStringAsFixed(2)}',
                TextStyle(
                  color: theme.colorScheme.onInverseSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            touchCallback: (_, response) => setState(
              () => _touchedIndex = response?.spot?.touchedBarGroupIndex,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: _bottomLabel,
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
        swapAnimationDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  List<BarChartGroupData> _categoryGroups(ThemeData theme) {
    return widget.categoryData.asMap().entries.map((entry) {
      final isTouched = entry.key == _touchedIndex;
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.total,
            color: entry.value.category.color,
            width: isTouched ? 20 : 14,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }

  List<BarChartGroupData> _monthGroups(ThemeData theme) {
    return widget.monthlyData.asMap().entries.map((entry) {
      final isTouched = entry.key == _touchedIndex;
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.total,
            color: theme.colorScheme.primary,
            width: isTouched ? 20 : 14,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }

  Widget _bottomLabel(double value, TitleMeta meta) {
    final theme = Theme.of(context);
    final style = TextStyle(
      fontSize: 10,
      color: theme.colorScheme.onSurfaceVariant,
    );
    final i = value.toInt();
    String label;
    if (_isMonthMode) {
      if (i < 0 || i >= widget.categoryData.length) {
        return const SizedBox.shrink();
      }
      final name = widget.categoryData[i].category.name;
      label = name.length > 5 ? name.substring(0, 5) : name;
    } else {
      const abbr = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
      if (i < 0 || i >= abbr.length) return const SizedBox.shrink();
      label = abbr[i];
    }
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(label, style: style),
    );
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.period});

  final DashboardPeriod period;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 220,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_outlined,
            size: 56,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'No expenses this ${period.label.toLowerCase()}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
