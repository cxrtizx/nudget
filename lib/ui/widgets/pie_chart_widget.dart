import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:nudget/providers/dashboard_providers.dart';

/// Pie chart that visualises per-category spending for the active period.
///
/// Tapping a segment calls [onSectionTapped] with the corresponding
/// [CategorySpendingData.category] id so the caller can filter a list.
/// Tapping outside any segment calls [onSectionTapped] with `null` to
/// clear the filter.
class PieChartWidget extends StatefulWidget {
  /// Creates a [PieChartWidget].
  const PieChartWidget({
    required this.data,
    this.onSectionTapped,
    super.key,
  });

  /// Per-category spending breakdown for the active period.
  final List<CategorySpendingData> data;

  /// Called with the selected category id, or `null` when deselected.
  final ValueChanged<String?>? onSectionTapped;

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) return _EmptyState();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: _onTouch,
              ),
              sections: _buildSections(),
              centerSpaceRadius: 48,
              sectionsSpace: 2,
            ),
            swapAnimationDuration: const Duration(milliseconds: 300),
          ),
        ),
        const SizedBox(height: 16),
        _Legend(data: widget.data),
      ],
    );
  }

  void _onTouch(FlTouchEvent event, PieTouchResponse? response) {
    if (!event.isInterestedForInteractions ||
        response == null ||
        response.touchedSection == null) {
      if (_touchedIndex != null) {
        setState(() => _touchedIndex = null);
        widget.onSectionTapped?.call(null);
      }
      return;
    }
    final index = response.touchedSection!.touchedSectionIndex;
    if (index < 0 || index >= widget.data.length) return;
    setState(() => _touchedIndex = index);
    widget.onSectionTapped?.call(widget.data[index].category.id);
  }

  List<PieChartSectionData> _buildSections() {
    return widget.data.asMap().entries.map((entry) {
      final isTouched = entry.key == _touchedIndex;
      final item = entry.value;
      return PieChartSectionData(
        value: item.total,
        color: item.category.color,
        radius: isTouched ? 72 : 60,
        title: '${item.percentage.toStringAsFixed(0)}%',
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black38, blurRadius: 4)],
        ),
        titlePositionPercentageOffset: 0.7,
      );
    }).toList();
  }
}

// ---------------------------------------------------------------------------
// Private sub-widgets
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 220,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pie_chart_outline,
            size: 56,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'No expenses in this period',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.data});

  final List<CategorySpendingData> data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: data.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: item.category.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${item.category.name}  €${item.total.toStringAsFixed(2)}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        );
      }).toList(),
    );
  }
}
