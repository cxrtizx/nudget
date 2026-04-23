import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_notification_listener/flutter_notification_listener.dart';
import 'package:nudget/core/models/expense.dart';
import 'package:nudget/core/models/notification_source.dart';
import 'package:nudget/core/services/notification_parser.dart';
import 'package:nudget/data/local/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

/// Notification callback invoked by [flutter_notification_listener] when a
/// notification arrives. Runs in two contexts:
///
/// * **Main isolate** (app in foreground/background): routes the event through
///   the [IsolateNameServer] port so [AndroidNotificationListener] can pick it
///   up via its stream.
/// * **Background isolate** (app closed with swipe or after reboot): the main
///   port is absent, so the event is processed directly — parsed, classified,
///   and persisted to SQLite without Riverpod.
///
/// Must be a top-level function. The pragma prevents tree-shaking in release.
@pragma('vm:entry-point')
Future<void> backgroundNotificationHandler(NotificationEvent event) async {
  // Route to the main isolate when it is alive (app in foreground/background).
  final sendPort = IsolateNameServer.lookupPortByName(
    NotificationsListener.SEND_PORT_NAME,
  );
  if (sendPort != null) {
    sendPort.send(event);
    return;
  }

  // Main isolate is gone — process directly in this background isolate.
  WidgetsFlutterBinding.ensureInitialized();

  final body    = event.text        ?? '';
  final title   = event.title       ?? '';
  final pkgName = event.packageName ?? '';
  final rawText = '$title\n$body'.trim();

  final db = await DatabaseHelper.instance.database;

  // 1. Try a user-configured NotificationSource matching by package name.
  final sourceMaps = await db.query(
    'notification_sources',
    where: 'is_enabled = 1 AND app_name = ?',
    whereArgs: [pkgName],
  );

  ParsedExpenseData? parsed;
  if (sourceMaps.isNotEmpty) {
    final source = NotificationSource.fromMap(
      Map<String, dynamic>.from(sourceMaps.first),
    );
    parsed = source.parse(body, source: pkgName);
  }

  // 2. Fall back to built-in regex patterns.
  parsed ??= const NotificationParser().parse(body, source: pkgName);

  // 3. Build the expense record.
  final now = DateTime.now();
  var expense = Expense(
    id: const Uuid().v4(),
    amount: parsed?.amount ?? 0,
    description:
        parsed?.description ?? (title.isNotEmpty ? title : pkgName),
    date: now,
    notificationSource: pkgName,
    autoClassified: false,
    rawNotificationText: rawText,
    createdAt: now.toUtc(),
  );

  // 4. If an amount was found, auto-classify via stored rules.
  if (parsed != null) {
    final ruleMaps = await db.query(
      'classification_rules',
      orderBy: 'match_count DESC',
    );
    for (final row in ruleMaps) {
      final pattern = row['pattern'] as String;
      final regex = RegExp(pattern, caseSensitive: false, unicode: true);
      if (regex.hasMatch(expense.description)) {
        expense = expense.copyWith(
          categoryId: row['category_id'] == null
              ? null
              : '${row['category_id']}',
          autoClassified: true,
        );
        await db.rawUpdate(
          'UPDATE classification_rules'
          ' SET match_count = match_count + 1 WHERE id = ?',
          [row['id']],
        );
        break;
      }
    }
  }

  await db.insert(
    'expenses',
    expense.toMap(),
    conflictAlgorithm: ConflictAlgorithm.ignore,
  );
}
