import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nudget/core/models/expense.dart';
import 'package:nudget/core/services/i_notification_listener_service.dart';
import 'package:nudget/core/services/notification_parser.dart';
import 'package:nudget/core/utils/logger.dart';
import 'package:nudget/platform/android/android_notification_listener.dart';
import 'package:nudget/platform/ios/ios_notification_listener.dart';
import 'package:nudget/providers/classification_service_provider.dart';
import 'package:nudget/providers/expense_providers.dart';
import 'package:nudget/providers/repository_providers.dart';
import 'package:uuid/uuid.dart';

/// Provides the platform-appropriate [INotificationListenerService].
///
/// - Android → [AndroidNotificationListener] backed by the system
///   `NotificationListenerService` foreground service.
/// - iOS / other → [IosNotificationListener] stub that never emits.
final notificationListenerProvider =
    Provider<INotificationListenerService>((ref) {
  if (Platform.isAndroid) {
    final listener = AndroidNotificationListener();
    ref.onDispose(listener.dispose);
    return listener;
  }
  return const IosNotificationListener();
});

/// Keeps the end-to-end notification → classification pipeline alive for the
/// lifetime of the app.
///
/// For each incoming [RawNotificationData]:
/// 1. [NotificationParser] extracts the amount and merchant description.
/// 2. An [Expense] record is constructed from the parsed data.
/// 3. The classification service attempts automatic category assignment.
///    If parsing failed (amount unknown) the expense is saved directly as
///    unclassified with `amount == 0`.
/// 4. [expenseListProvider] and [unclassifiedExpensesProvider] are refreshed so
///    the dashboard badge and expense list update immediately.
///
/// The stream subscription is cancelled automatically when the provider is
/// disposed (app teardown).
final notificationPipelineProvider = Provider<void>((ref) {
  final listener = ref.watch(notificationListenerProvider);
  const parser = NotificationParser();
  const uuid = Uuid();
  const log = Logger('NotificationPipeline');

  final subscription = listener.notificationStream.listen(
    (notification) async {
      final parsed =
          parser.parse(notification.body, source: notification.appName);
      final now = DateTime.now().toUtc();

      // Combine title + body for the raw text archive.
      final rawText = notification.title.isNotEmpty
          ? '${notification.title}: ${notification.body}'
          : notification.body;

      final expense = Expense(
        id: uuid.v4(),
        amount: parsed?.amount ?? 0,
        description: parsed?.description ?? notification.title,
        date: notification.timestamp,
        notificationSource: notification.appName,
        autoClassified: false,
        rawNotificationText: rawText,
        createdAt: now,
      );

      try {
        if (parsed != null) {
          // classify() saves the expense and attempts auto-categorisation.
          await ref.read(classificationServiceProvider).classify(expense);
          log.info(
            'Classified notification from ${notification.appName}: '
            '€${parsed.amount} — ${parsed.description}',
          );
        } else {
          // No amount found — save as unclassified for manual review.
          await ref.read(expenseRepositoryProvider).save(expense);
          log.info(
            'Saved unparsed notification from ${notification.appName} '
            'as unclassified expense',
          );
        }
      } catch (e, st) {
        log.error('Pipeline failed to process notification', e, st);
        return;
      }

      // Refresh UI providers so the badge count and lists update.
      await ref.read(expenseListProvider.notifier).refresh();
      await ref.read(unclassifiedExpensesProvider.notifier).refresh();
    },
    onError: (Object e, StackTrace st) =>
        log.error('Notification stream error', e, st),
  );

  ref.onDispose(subscription.cancel);
});
