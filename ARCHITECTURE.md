# Architecture

## Framework: Flutter

This project was built with Flutter as a deliberate decision to expand beyond a consolidated .NET background
(C#, WPF, desktop environments). Flutter and Dart share key paradigms with C#: strict static typing,
class-based object orientation, interfaces, and abstract classes — allowing well-known architectural patterns
(repositories, dependency injection, service layers) to be applied without conceptual friction, while focusing
the learning effort on what is genuinely new: the reactive widget model and native iOS/Android API integration.

Flutter was chosen over .NET MAUI intentionally. MAUI would have been the natural extension of the existing
stack but would not demonstrate technological adaptability. Flutter currently leads the cross-platform mobile
market with 46% share and is backed by Google with a mature ecosystem.


## Folder Structure

```
lib/
  core/
    models/           # Domain entities: Expense, Category, ClassificationRule
    repositories/     # Abstract interfaces: IRepository, IExpenseRepository, ICategoryRepository
    services/         # Business logic: ClassificationService, NotificationParser
    utils/            # Helpers, extensions, domain constants
  platform/
    android/          # Native notification listener implementation
    ios/              # Native notification listener implementation (stub)
  ui/
    screens/          # One subfolder per screen: dashboard, expenses, categories, pending, statistics
    widgets/          # Reusable components: ExpenseListItem, CategoryCard, PieChartWidget, BarChartWidget
    theme/            # Colors, typography, light/dark theme
  data/
    local/            # Concrete repository implementations using sqflite
    migrations/       # Table creation scripts and seed data
  providers/          # Riverpod provider definitions
  main.dart
  app.dart            # MaterialApp, routes, dependency injection bootstrap
  routes.dart         # go_router configuration with typed route constants
```

---

## State Management

Riverpod (`flutter_riverpod`) is used as the sole state management and dependency injection solution.

- `AsyncNotifierProvider` — for data sourced from repositories (async I/O)
- `NotifierProvider` — for synchronous UI state (active filter period, selected category, etc.)
- Repositories are injected via `Provider`, never instantiated directly inside widgets.

## Navigation

`go_router` provides declarative, URL-based navigation. All route paths are defined as constants in
`lib/routes.dart`. No `Navigator.push` calls appear in the codebase.

## Persistence

`sqflite` is the local database. A `DatabaseHelper` singleton manages the lifecycle. Schema versioning
starts at version 1 with an `onUpgrade` hook ready for future migrations. The app is fully offline-first —
no network calls of any kind.

## Code Quality

- `very_good_analysis` lint ruleset enforced via `analysis_options.yaml`
- Immutable domain models via `freezed`
- Null safety enforced throughout; `late` is avoided unless justified
- `dynamic` is prohibited; generics are used instead
- All async operations handle errors explicitly — no empty `catch` blocks

## Naming Conventions

| Scope | Convention | Example |
|---|---|---|
| Files | snake_case | `expense_repository.dart` |
| Classes | PascalCase | `ExpenseRepository` |
| Variables / methods | camelCase | `findByDateRange` |
| Constants | camelCase with `k` prefix | `kDefaultCategories` |
| Interfaces / abstracts | `I` prefix | `IExpenseRepository` |
