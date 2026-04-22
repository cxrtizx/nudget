import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nudget/core/utils/l10n_extension.dart';
import 'package:nudget/ui/screens/categories/categories_screen.dart';
import 'package:nudget/ui/screens/dashboard/dashboard_screen.dart';
import 'package:nudget/ui/screens/expenses/expenses_screen.dart';
import 'package:nudget/ui/screens/pending/pending_screen.dart';
import 'package:nudget/ui/screens/statistics/statistics_screen.dart';

/// Route path constants.
const kRouteDashboard = '/';

/// Route path for the expenses list screen.
const kRouteExpenses = '/expenses';

/// Route path for the categories management screen.
const kRouteCategories = '/categories';

/// Route path for the pending classification screen.
///
/// Pushed modally on top of the shell; not a bottom-nav tab.
const kRoutePending = '/pending';

/// Route path for the statistics screen.
const kRouteStatistics = '/statistics';

/// Ordered list of paths that correspond to bottom-navigation tabs.
const _tabRoutes = [
  kRouteDashboard,
  kRouteExpenses,
  kRouteCategories,
  kRouteStatistics,
];

/// Application router — single source of truth for all navigation.
///
/// Uses a [ShellRoute] to host a persistent [NavigationBar] across the four
/// main tabs. [kRoutePending] sits outside the shell so it pushes as a
/// full-screen route without the navigation bar.
final GoRouter appRouter = GoRouter(
  initialLocation: kRouteDashboard,
  routes: [
    ShellRoute(
      builder: (context, state, child) => _AppShell(
        location: state.matchedLocation,
        child: child,
      ),
      routes: [
        GoRoute(
          path: kRouteDashboard,
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: kRouteExpenses,
          builder: (context, state) => const ExpensesScreen(),
        ),
        GoRoute(
          path: kRouteCategories,
          builder: (context, state) => const CategoriesScreen(),
        ),
        GoRoute(
          path: kRouteStatistics,
          builder: (context, state) => const StatisticsScreen(),
        ),
      ],
    ),
    // Pending is a push-only route — no bottom nav tab.
    GoRoute(
      path: kRoutePending,
      builder: (context, state) => const PendingScreen(),
    ),
  ],
);

// ---------------------------------------------------------------------------
// Shell widget
// ---------------------------------------------------------------------------

/// Wraps [child] with a [NavigationBar] that stays visible across the four
/// main tabs. Uses [location] to highlight the active destination.
class _AppShell extends StatelessWidget {
  const _AppShell({required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tabIndex = _resolveTabIndex(location);
    // NavigationDestination labels come from l10n so they react to locale
    // changes without any extra state — Flutter rebuilds the widget tree
    // whenever the inherited Localizations widget changes.
    final l10n = context.l10n;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: tabIndex,
        onDestinationSelected: (i) => context.go(_tabRoutes[i]),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: l10n.navExpenses,
          ),
          NavigationDestination(
            icon: const Icon(Icons.category_outlined),
            selectedIcon: const Icon(Icons.category),
            label: l10n.navCategories,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: l10n.navStatistics,
          ),
        ],
      ),
    );
  }

  /// Returns the tab index whose route prefix matches [location], defaulting
  /// to 0 (Home) when no tab matches (e.g. during an animation).
  static int _resolveTabIndex(String location) {
    for (var i = 0; i < _tabRoutes.length; i++) {
      final route = _tabRoutes[i];
      if (route == '/' ? location == '/' : location.startsWith(route)) {
        return i;
      }
    }
    return 0;
  }
}
