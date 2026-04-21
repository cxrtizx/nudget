import 'package:flutter/material.dart';
import 'package:nudget/providers/period_filter_provider.dart';

/// Segmented button row for selecting the dashboard period.
///
/// Renders all four [DashboardPeriod] values as segments. Calls [onSelect]
/// with the newly chosen value whenever the selection changes.
class PeriodSelector extends StatelessWidget {
  /// Creates a [PeriodSelector].
  const PeriodSelector({
    required this.selected,
    required this.onSelect,
    super.key,
  });

  /// Currently active period — determines which segment is highlighted.
  final DashboardPeriod selected;

  /// Callback invoked when the user taps a different segment.
  final ValueChanged<DashboardPeriod> onSelect;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<DashboardPeriod>(
      segments: DashboardPeriod.values
          .map(
            (p) => ButtonSegment<DashboardPeriod>(
              value: p,
              label: Text(p.label),
            ),
          )
          .toList(),
      selected: {selected},
      onSelectionChanged: (set) => onSelect(set.first),
    );
  }
}
