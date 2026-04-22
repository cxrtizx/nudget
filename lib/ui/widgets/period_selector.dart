import 'package:flutter/material.dart';
import 'package:nudget/core/utils/l10n_extension.dart';
import 'package:nudget/l10n/app_localizations.dart';
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
      showSelectedIcon: false,
      segments: DashboardPeriod.values
          .map(
            (p) => ButtonSegment<DashboardPeriod>(
              value: p,
              // localizedLabel resolves the period to the correct locale.
              label: Text(p.localizedLabel(context.l10n)),
            ),
          )
          .toList(),
      selected: {selected},
      onSelectionChanged: (set) => onSelect(set.first),
    );
  }
}

/// Extension that maps each [DashboardPeriod] to its localized label.
///
/// Why an extension instead of modifying the enum? The enum lives in the
/// provider layer, which has no access to [BuildContext] or l10n. An
/// extension in the UI layer keeps the layers separate and avoids importing
/// Flutter widgets into provider code.
extension DashboardPeriodL10n on DashboardPeriod {
  /// Returns the label for this period in the current app locale.
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        DashboardPeriod.day => l10n.periodDay,
        DashboardPeriod.week => l10n.periodWeek,
        DashboardPeriod.month => l10n.periodMonth,
        DashboardPeriod.year => l10n.periodYear,
      };
}
