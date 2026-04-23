import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nudget/core/repositories/i_category_repository.dart';
import 'package:nudget/core/repositories/i_classification_rule_repository.dart';
import 'package:nudget/core/repositories/i_expense_repository.dart';
import 'package:nudget/core/repositories/i_notification_source_repository.dart';
import 'package:nudget/data/local/database_helper.dart';
import 'package:nudget/data/local/sqlite_category_repository.dart';
import 'package:nudget/data/local/sqlite_classification_rule_repository.dart';
import 'package:nudget/data/local/sqlite_expense_repository.dart';
import 'package:nudget/data/local/sqlite_notification_source_repository.dart';

/// Provides the application-wide [DatabaseHelper] singleton.
///
/// Override this provider in tests to inject a [DatabaseHelper.forTesting]
/// instance backed by an in-memory database.
final databaseHelperProvider = Provider<DatabaseHelper>(
  (ref) => DatabaseHelper.instance,
  name: 'databaseHelperProvider',
);

/// Provides the [ICategoryRepository] implementation.
final categoryRepositoryProvider = Provider<ICategoryRepository>(
  (ref) => SqliteCategoryRepository(ref.watch(databaseHelperProvider)),
  name: 'categoryRepositoryProvider',
);

/// Provides the [IExpenseRepository] implementation.
final expenseRepositoryProvider = Provider<IExpenseRepository>(
  (ref) => SqliteExpenseRepository(ref.watch(databaseHelperProvider)),
  name: 'expenseRepositoryProvider',
);

/// Provides the [IClassificationRuleRepository] implementation.
final classificationRuleRepositoryProvider =
    Provider<IClassificationRuleRepository>(
  (ref) => SqliteClassificationRuleRepository(
    ref.watch(databaseHelperProvider),
  ),
  name: 'classificationRuleRepositoryProvider',
);

/// Provides the [INotificationSourceRepository] implementation.
final notificationSourceRepositoryProvider =
    Provider<INotificationSourceRepository>(
  (ref) => SqliteNotificationSourceRepository(
    ref.watch(databaseHelperProvider),
  ),
  name: 'notificationSourceRepositoryProvider',
);
