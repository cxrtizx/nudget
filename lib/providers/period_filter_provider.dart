import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dashboard period options for the segmented button selector.
enum DashboardPeriod {
  /// Single calendar day. Renders a [PieChartWidget].
  day,

  /// Monday–Sunday calendar week. Renders a [PieChartWidget].
  week,

  /// Calendar month. Renders a [BarChartWidget] (category breakdown).
  month,

  /// Calendar year. Renders a [BarChartWidget] (month-by-month totals).
  year;

  /// Human-readable label shown in the segmented button.
  String get label => switch (this) {
        day => 'Day',
        week => 'Week',
        month => 'Month',
        year => 'Year',
      };

  /// Whether this period uses the pie chart variant.
  bool get usesPieChart => this == day || this == week;
}

/// Notifier that owns the currently selected [DashboardPeriod].
class PeriodFilterNotifier extends Notifier<DashboardPeriod> {
  @override
  DashboardPeriod build() => DashboardPeriod.week;

  /// Updates the active period selection.
  void select(DashboardPeriod period) => state = period;
}

/// Provides the active [DashboardPeriod] for the dashboard screen.
///
/// Synchronous — uses [NotifierProvider] as per the architectural conventions.
final periodFilterProvider =
    NotifierProvider<PeriodFilterNotifier, DashboardPeriod>(
  PeriodFilterNotifier.new,
);

/// Computes the [DateTimeRange] that corresponds to the active [DashboardPeriod]
/// relative to today's date.
final activeDateRangeProvider = Provider<({DateTime from, DateTime to})>((ref) {
  final period = ref.watch(periodFilterProvider);
  final now = DateTime.now();

  return switch (period) {
    DashboardPeriod.day => (
        from: DateTime(now.year, now.month, now.day),
        to: DateTime(now.year, now.month, now.day, 23, 59, 59),
      ),
    DashboardPeriod.week => _currentWeekRange(now),
    DashboardPeriod.month => (
        from: DateTime(now.year, now.month),
        to: DateTime(now.year, now.month + 1).subtract(const Duration(seconds: 1)),
      ),
    DashboardPeriod.year => (
        from: DateTime(now.year),
        to: DateTime(now.year + 1).subtract(const Duration(seconds: 1)),
      ),
  };
});

/// Returns Monday 00:00 → Sunday 23:59:59 for the week containing [date].
({DateTime from, DateTime to}) _currentWeekRange(DateTime date) {
  final monday = date.subtract(Duration(days: date.weekday - 1));
  final from = DateTime(monday.year, monday.month, monday.day);
  final to = from.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
  return (from: from, to: to);
}
